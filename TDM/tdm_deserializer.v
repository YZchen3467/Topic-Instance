module tdm_deserializer (
	clock,
	reset,
	tdm_data,
	tdm_sync,
	tdm_clk,
	word_ready,
	ch0,
	ch1,
	ch2,
	ch3,
	ch4	
);

//----- Parameters   -----
parameter SIZE_32T = 32	;
parameter SIZE_08T = 8	;
parameter CH0_DEC = 4'h0;
parameter CH1_DEC = 4'h1;
parameter CH2_DEC = 4'h2;
parameter CH3_DEC = 4'h3;
parameter CH4_DEC = 4'h4;
parameter IDLE	  = 4'hF;

//----- Input Ports  -----
input clock	;
input reset	;
input tdm_data	;
input tdm_sync	;
input tdm_clk	;

//----- Output Ports -----
output word_ready	 ;
output [SIZE_32T-1:0] ch0;
output [SIZE_32T-1:0] ch1;
output [SIZE_32T-1:0] ch2;
output [SIZE_32T-1:0] ch3;
output [SIZE_32T-1:0] ch4;

//----- Registers    -----
reg			ready	;
reg [SIZE_08T-1:0]	count 	;
reg [SIZE_32T-1:0]	ch0_data;
reg [SIZE_32T-1:0]	ch1_data;
reg [SIZE_32T-1:0]	ch2_data;
reg [SIZE_32T-1:0]	ch3_data;
reg [SIZE_32T-1:0]	ch4_data;

assign word_ready = ready;
assign ch0 = ch0_data;
assign ch1 = ch1_data;
assign ch2 = ch2_data;
assign ch3 = ch3_data;
assign ch4 = ch4_data;

always @ (posedge tdm_clk or posedge reset)	
begin
	if (reset) begin
		count 	 = 8'hFF;
		ch0_data = 8'h00;
		ch1_data = 8'h00;
		ch2_data = 8'h00;
		ch3_data = 8'h00;
		ch4_data = 8'h00;
		ready	 = 1'b0;
	end else begin
		case(count[7:4]) 
			IDLE:   begin				
					if (tdm_sync == 1'b1) begin
						count <= 8'h00;
					end
					if (ready == 1'b1) begin
						ready <= 1'b0;
					end
				end
			CH0_DEC:begin
					ch0_data <= {ch0_data[30:0], tdm_data};
					count 	 <= (count + 1'b1);
				end 
			CH1_DEC:begin
					ch1_data <= {ch1_data[30:0], tdm_data};
					count 	 <= count + 1;
				end 
			CH2_DEC:begin
					ch2_data <= {ch2_data[30:0], tdm_data};
					count 	 <= count + 1;
				end 
			CH3_DEC:begin
					ch3_data <= {ch3_data[30:0], tdm_data};
					count 	 <= count + 1;
				end 
			CH4_DEC:begin
					ch4_data <= {ch4_data[30:0], tdm_data};
					if (count == 8'h4F) begin
						count <= 8'hFF;
						ready <= 1'b1;
					end else begin
						count <= count + 1;
					end
				end 
		endcase
	end
end

endmodule
