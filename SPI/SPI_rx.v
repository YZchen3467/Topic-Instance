//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : SPI_rx.v
//   Module Name : SPI_rx
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module SPI_rx(
				// input
				clk,
				rst_n,
				
				sclk_divider,
				rd_en,
				tx_wr_data,
				
				// output
				rd_done,
				rd_data,
				
				// SPI interface
				SPI_miso,
				SPI_mosi,
				SPI_sclk,
				SPI_csn
			  );

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================	
// input 			
input        clk;
input		 rst_n;

input        sclk_divider; 
input        rd_en;
input [7:0]  tx_wr_data;

// output
output reg   rd_done;
output [7:0] rd_data;

// SPI
input 	     SPI_miso;
output       SPI_mosi;
output reg   SPI_sclk;
output reg   SPI_csn;

//================================================================
//  Wires & Registers
//================================================================
reg r_sclk_en;				// SPI_SCLK enable, but not port type. 
reg	[7:0] r_sclk_divider;	// let r_sclk_divider == sclk_divider and do sth.
reg r_sclk_edge;			// to Generate SPI_SCLK posedge and negedge.
reg [3:0] r_bit_cnt;		// counting the bit number.
reg [7:0] r_data;			// data register

reg [2:0] curr_state;
reg [2:0] next_state;

wire w_sclk_posedge;        // using r_sclk_edge to generate spi posedge
wire w_sclk_negedge;		// using r_sclk_edge to generate spi negedge

//================================================================
//  integer / genvar / parameters
//================================================================
localparam IDLE 		= 3'd00;
localparam CSN_EN 		= 3'd01; 
localparam READ_DATA 	= 3'd02; 
localparam CSN_DISABLE	= 3'd03;
localparam FINISH 		= 3'd04;

//================================================================
//  Generate SPI clk
//================================================================
always @(posedge clk) begin
	if(!rst_n)
		r_sclk_divider <= 8'd0;
	else if(r_sclk_en) begin
		if(r_sclk_divider == sclk_divider)
			r_sclk_divider <= 8'd0;
		else
			r_sclk_divider <= r_sclk_divider + 1'b1;
	end
	else
		r_sclk_divider <= 8'd0;
end

always @(posedge clk) begin
	if(!rst_n)
		SPI_sclk <= 1'b0;
	else if(r_sclk_en) begin
		if(r_sclk_divider == sclk_divider)
			SPI_sclk <= ~SPI_sclk;
	end
	else
		SPI_sclk <= 1'b0;
end

always @(posedge clk) begin
	if(!rst_n)
		r_sclk_edge <= 1'b0;
	else
		r_sclk_edge <= SPI_sclk;
end

assign w_sclk_posedge = (~r_sclk_edge) & SPI_sclk;
assign w_sclk_negedge = r_sclk_edge & (~SPI_sclk);

//================================================================
//  FSM
//================================================================
always @(posedge clk) begin
	if(!rst_n)
		curr_state <= IDLE;
	else
		curr_state <= next_state;
end

always @(*) begin
	next_state = IDLE;
	case(curr_state)
		IDLE: begin
			if(rd_en)
				next_state = CSN_EN;
			else
				next_state = IDLE;
		end
		
		CSN_EN: begin
			if(w_sclk_negedge) begin
				if(rd_en)
					next_state = READ_DATA;
				else
					next_state = CSN_EN;
			end
			else
				next_state = CSN_EN;
		end
		
		READ_DATA: begin
			if((r_bit_cnt == 4'd8) & w_sclk_posedge)
				next_state = CSN_DISABLE;
			else
				next_state = READ_DATA;
		end
		
		CSN_DISABLE: begin
			if(w_sclk_negedge)
				next_state = FINISH;
			else
				next_state = CSN_DISABLE;
		end
		
		FINISH: begin
			next_state = IDLE;
		end
		
		default: begin
			next_state = IDLE;
		end
	endcase
end

always @(posedge clk) begin
	if(!rst_n) begin
		r_sclk_en <= 1'b0;
		r_bit_cnt <= 4'd0;
		r_data    <= 8'd0;
		SPI_csn	  <= 1'b1;
		rd_done   <= 1'b0;
	end
	else begin
		case(curr_state)
			IDLE: begin
				r_sclk_en <= 1'b0;
				r_bit_cnt <= 4'd0;
				r_data    <= 8'd0;
				rd_done   <= 1'b0;
			end
			
			CSN_EN: begin
				r_sclk_en <= 1'b1;
				rd_done   <= 1'b0;
				if(w_sclk_negedge) begin
					// r_data    <= tx_wr_data; // loading input data and standby to output
					SPI_csn   <= 1'b0;
					r_data	  <= {r_data[6:0], SPI_miso}; // solve the first bit lose
				end
			end
			
			READ_DATA: begin
				if(w_sclk_posedge) begin
					if(r_bit_cnt == 4'd8)
						r_data    <= r_data;
					else begin
						r_data	  <= {r_data[6:0], SPI_miso}; 
						r_bit_cnt <= r_bit_cnt + 1'b1;
					end
				end
			end
			
			CSN_DISABLE: begin
				rd_done   <= 1'b0;
				SPI_csn   <= 1'b1;
			end
			
			FINISH: begin
				rd_done <= 1'b1;
			end
			
			default: begin
				r_sclk_en <= 1'b0;
				r_bit_cnt <= 4'd0;
				r_data    <= 8'd0;	
				SPI_csn	  <= 1'b1;	
				rd_done   <= 1'b0;	
			end
		endcase
	end
end

assign rd_data = (r_bit_cnt == 4'd7) ? r_data : 8'd0;

endmodule