//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : SPI_rx_PATTERN.v
//   Module Name : SPI_rx_PATTERN
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`ifdef RTL
	`timescale 1ns/10ps
`endif

module SPI_rx_PATTERN(
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
output reg  clk;
output reg  rst_n;
	     
output reg  sclk_divider; 
output reg  rd_en;
output reg  [7:0] tx_wr_data;

// output
input		rd_done;
input [7:0]	rd_data;

// SPI
output reg  SPI_miso;
input 	    SPI_mosi;
input 	    SPI_sclk;
input 	    SPI_csn;

//================================================================
//  Wires & Registers
//================================================================
reg [2:0] bit_index;
reg [7:0] r_py_data;

//================================================================
//  parameters & integer
//================================================================
integer PATNUM;
integer patcount;
integer pat_file, write_in;

//================================================================
//  clock
//================================================================
initial clk = 0 ;
always #50 clk = ~clk;

//================================================================
//  INITIAL                         
//================================================================
initial begin
	pat_file = $fopen("pattern.txt", "r");
	write_in = $fscanf(pat_file, "%d\n", PATNUM);
	
	clk 			= 1'b0;
	SPI_miso 		= 1'b0;
	rd_en 			= 1'b0;
	sclk_divider 	= 8'd0;
	rst_n 			= 1'b0;
	
	#100
	rst_n 			= 1'b1;
	
	@(negedge clk);
	for(patcount=0; patcount < PATNUM; patcount = patcount + 1) begin
		read_data;
		if(patcount < PATNUM)
			$display(patcount + 1);
	end
	
	#(500);
	$finish;
	
end

//================================================================
//  Read Data                         
//================================================================
task read_data; begin
	rd_en = 1'b1;
	sclk_divider = 8'd1;
	write_in = $fscanf(pat_file, "%h", r_py_data);
	bit_index = 0;
	while (rd_done != 1'b1) begin
		repeat(2) @(negedge clk);
		if(SPI_sclk == 1'b1)begin
			if(bit_index == 0)
				SPI_miso <= r_py_data[7];
			else if(bit_index == 1)
				SPI_miso <= r_py_data[6];
			else if(bit_index == 2)
				SPI_miso <= r_py_data[5];
			else if(bit_index == 3)
				SPI_miso <= r_py_data[4];
			else if(bit_index == 4)
		    	SPI_miso <= r_py_data[3];
			else if(bit_index == 5)
		    	SPI_miso <= r_py_data[2];
			else if(bit_index == 6)
		    	SPI_miso <= r_py_data[1];
			else if(bit_index == 7)
		    	SPI_miso <= r_py_data[0];
			bit_index = bit_index + 1'b1;
			if(bit_index > 7) begin
				bit_index = 3'd0;
			end
		end
	end
	rd_en = 1'b0;
	repeat(10) @(negedge clk);
end endtask

endmodule