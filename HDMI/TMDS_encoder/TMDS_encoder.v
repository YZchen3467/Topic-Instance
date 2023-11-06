//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : TMDS_encoder.v
//   Module Name : TMDS_encoder
//	 SPEC:
//	 **************************************
//	 | input control bit |    output      |	
//	 |*******************|   codeword     |
//	 |	 C0    |    C1   |                |
//	 *************************************|
//	 |	  0	   |    0    |   0010101011   |	=>	transmit the position information
//	 |************************************|		of the data sampling phase									 
//   |    0    |    1    |   1101010100   | =>  HDMI data clock(pixel clcok) frequency
//   |************************************|		information
//   |    1    |    0    |   0010101010   | =>	transmit information about the reverse
//   |************************************|		phase in the data sampling (complement 0010101011)
//   |    1    |    1    |   1101010101   | =>	transmit information about the reverse
//	 |************************************|		frequency in the data clock (complement 1101010100)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module TMDS_encoder( // input
						clk,
						rst_n,
						i_din,
						i_c0,
						i_c1,
						i_de,
						
					 // output
						o_dout
					);
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
// INPUT
input clk; 						// system clk
input rst_n; 					// ststem reset, negative actived
input [7:0] i_din; 				// data input
input i_de;						// data enable
input i_c0, i_c1;				// input control bit

// OUTPUT
output reg [9:0] o_dout;		// output data


//================================================================
//  integer / genvar / parameters
//================================================================
// codeword [0:9] is 00_1010_1011, therefore [9:0] 11_0101_0100, and so on.
localparam	CTRLTOKEN0	=	10'b11_0101_0100;		// HEX = 354
localparam	CTRLTOKEN1  =	10'b00_1010_1011;       // HEX = 0AB
localparam  CTRLTOKEN2  =	10'b01_0101_0100;       // HEX = 154
localparam  CTRLTOKEN3  =	10'b10_1010_1011;       // HEX = 2AB


//================================================================
//  Wires & Registers
//================================================================
/* decision */
wire w_decision_1;
wire w_decision_2;
wire w_decision_3;

reg  [3:0] r_dnum_of_1;
reg  [7:0] r_data;			// for din buffer input. if have not r_data
							// buffer, when din coming q_m always have value.
							// but r_data initial value is unknow, and every
							// cycle that update the single bit value.
wire [8:0] w_q_m;

reg  [3:0] r_qnum_of_0;
reg  [3:0] r_qnum_of_1;


/* counter for compare between current q_m and previous 
   curr q_m number of 1's/0's */
reg [4:0] r_cnt; 			// the cnt[4] is signed bit


/* delay register, becauz data_in should be through register that make the data_in delay
   one cycle period time. But dout should wait the d_in input and do encode, therefore 
   data_enable need to delay 2 cycle */
reg r_de_1, r_de_2;
reg r_c0_1, r_c0_2;
reg r_c1_1, r_c1_2;
reg [8:0] r_q_m;  			// for w_q_m delay


reg r_token_done;


//================================================================
//  number of 1 caculator in data
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		r_dnum_of_1 <= 4'd0;
		r_data		<= 8'b0;
	end
	else begin
		r_dnum_of_1 <= i_din[7] + i_din[6] + i_din[5] + i_din[4] + i_din[3] + i_din[2] + i_din[1] + i_din[0];
		r_data	  	<= i_din;
	end
end


//================================================================
//  TMDS algo 1st decision
//================================================================
assign w_decision_1 = (r_dnum_of_1 > 3'd4) | ((r_dnum_of_1 == 3'd4) & i_din[0]);

assign w_q_m[0] = i_din[0];
assign w_q_m[1] = w_decision_1 ? (w_q_m[0] ^ ~(r_data[1])) : (w_q_m[0] ^ r_data[1]);
assign w_q_m[2] = w_decision_1 ? (w_q_m[1] ^ ~(r_data[2])) : (w_q_m[1] ^ r_data[2]);
assign w_q_m[3] = w_decision_1 ? (w_q_m[2] ^ ~(r_data[3])) : (w_q_m[2] ^ r_data[3]);
assign w_q_m[4] = w_decision_1 ? (w_q_m[3] ^ ~(r_data[4])) : (w_q_m[3] ^ r_data[4]);
assign w_q_m[5] = w_decision_1 ? (w_q_m[4] ^ ~(r_data[5])) : (w_q_m[4] ^ r_data[5]);
assign w_q_m[6] = w_decision_1 ? (w_q_m[5] ^ ~(r_data[6])) : (w_q_m[5] ^ r_data[6]);
assign w_q_m[7] = w_decision_1 ? (w_q_m[6] ^ ~(r_data[7])) : (w_q_m[6] ^ r_data[7]);
assign w_q_m[8] = w_decision_1 ? 1'b0 : 1'b1;


//================================================================
//  number of 1 caculator in q_m
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		r_qnum_of_0 <= 4'd0;
		r_qnum_of_1 <= 4'd0;
	end
	else begin
		r_qnum_of_1 <= w_q_m[7] + w_q_m[6] + w_q_m[5] + w_q_m[4] + w_q_m[3] + w_q_m[2] + w_q_m[1] + w_q_m[0];
		r_qnum_of_0 <= 4'd8 - r_qnum_of_1;
	end
end


//================================================================
//  data delay for data synchronouns
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		r_de_1	<=	1'b0; 
	    r_de_2	<=	1'b0; 
			 
	    r_c0_1	<=	1'b0;
	    r_c0_2	<=  1'b0;
			 
	    r_c1_1	<=	1'b0;
	    r_c1_2	<=	1'b0; 
			 
	    r_q_m 	<= 	9'd0;
	end
	else begin
		r_de_1 	<= i_de;
		r_de_2 	<= r_de_1;
			
		r_c0_1 	<= i_c0;
		r_c0_2 	<= r_c0_1;
			
		r_c1_1 	<= i_c1;
		r_c1_2 	<= r_c1_1;
			
		r_q_m  	<= w_q_m;
	end
end


//================================================================
//  TMDS algo 2st decision
//================================================================
assign w_decision_2 = (r_cnt == 5'd0) | (r_qnum_of_0 == r_qnum_of_1);


//================================================================
//  TMDS algo 3rd decision
//================================================================
assign w_decision_3 = (~r_cnt[4] & (r_qnum_of_0 > r_qnum_of_1)) | (r_cnt[4] & (r_qnum_of_0 < r_qnum_of_1));


//================================================================
//  TMDS encoding
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		o_dout 			<= 10'd0;
		r_cnt  			<= 5'd0;
		r_token_done 	<= 1'b0;
	end
	else if(r_de_2) begin
		if(w_decision_2) begin
			o_dout[9]   <= ~r_q_m[8];
			o_dout[8]   <= r_q_m[8];
			o_dout[7:0] <= r_q_m[8] ? r_q_m[7:0] : ~(r_q_m[7:0]); 
			r_cnt 		<= r_q_m[8] ? (r_cnt + (r_qnum_of_0 - r_qnum_of_1)) : (r_cnt + (r_qnum_of_1 - r_qnum_of_0));
		end
		else begin
			if(w_decision_3) begin
				o_dout[9]   <= 1'b1;	
				o_dout[8]   <= r_q_m[8];	
				o_dout[7:0] <= ~(r_q_m[7:0]);
				r_cnt       <= r_cnt + 2*r_q_m[8] + (r_qnum_of_0 - r_qnum_of_1);
			end
			else begin
				o_dout[9]   <= 1'b0;	
				o_dout[8]   <= r_q_m[8];	
				o_dout[7:0] <= r_q_m[7:0];
				r_cnt       <= r_cnt + 2*(~r_q_m[8]) + (r_qnum_of_1 - r_qnum_of_0);
			end
		end 
	end
	else begin
		r_cnt 			<= 5'd0;
		case({r_c0_2, r_c0_2})
			2'b00 : o_dout <= CTRLTOKEN0;
			2'b01 : o_dout <= CTRLTOKEN1;
			2'b10 : o_dout <= CTRLTOKEN2;
			2'b11 : o_dout <= CTRLTOKEN3;
		endcase
	end
end

endmodule