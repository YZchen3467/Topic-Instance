//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : SPI_tx_PATTERN.v
//   Module Name : SPI_tx_PATTERN
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`ifdef RTL
	`timescale 1ns/10ps
`endif

module SPI_tx_PATTERN(
				// output
				clk,
				rst_n,
				
				sclk_divider,
				wr_en,
				tx_wr_data,
				
				// input
				wr_done,
				
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
output reg clk;
output reg rst_n;

output reg sclk_divider; 
output reg wr_en;
output reg [7:0] tx_wr_data;

// output
input wr_done;

//SPI
output reg SPI_miso;
input      SPI_mosi;
input      SPI_sclk;
input      SPI_csn;

//================================================================
//  parameters & integer
//================================================================
integer PATNUM;
integer patcount;
integer pat_file, a;

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
	a = $fscanf(pat_file, "%d\n", PATNUM);
	
	clk 			= 1'b0;
	SPI_miso 		= 1'b0;
	wr_en 			= 1'b0;
	sclk_divider 	= 8'd0;
	rst_n 			= 1'b0;
	
	#100
	rst_n 			= 1'b1;
	
	@(negedge clk);
	for(patcount=0; patcount < PATNUM; patcount = patcount + 1) begin
		write_data;
		if(patcount < PATNUM)
			$display(patcount + 1);
	end
	
	#(500);
	$finish;
	
end

//================================================================
//  Write Data                         
//================================================================
task write_data; begin
	wr_en = 1'b1;
	sclk_divider = 8'd1;
	a = $fscanf(pat_file, "%h", tx_wr_data);
	while (wr_done != 1) begin
		@(negedge clk);
	end
	wr_en = 1'b0;
	repeat(10) @(negedge clk);
end endtask
	
endmodule