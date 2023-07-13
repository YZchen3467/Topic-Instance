//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : SPI_Master_PATTERN.v
//   Module Name : SPI_Master_PATTERN
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`ifdef RTL
	`timescale 1ns/10ps
`endif

module SPI_Master_PATTERN(// OUTPUT
					clk, 
					rst_n,
					sclk_divider,
					wr_en,
					rd_en,
					/*start_addr,*/
					/*state_init,*/
					rx_rd_data,
					SPI_MISO,
					
					// INPUT
					wr_finish,
					rd_finish,
					tx_wr_data,
					SPI_SCLK,
					SPI_CSN,
					SPI_MOSI
					);

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
output reg clk; 				// System clk
output reg rst_n; 				// System reset, active low
output reg [7:0] sclk_divider; 	// SPI clk control / divid
output reg wr_en;				// Write enable
output reg rd_en;				// Read enable
/*output reg [7:0] start_addr;	 Write / Read Start address*/
/*output reg [7:0] state_init;	 slaver state initial*/
output reg [7:0] tx_wr_data;	// TX Write Data
output reg SPI_MISO;			// SPI Master input

// OUTPUT
input wr_finish;	// Write finish
input rd_finish;	// Read finish
input rx_rd_data;	// RX Read Data
input SPI_SCLK;		// SPI CLK
input SPI_CSN; 		// SPI chip sel
input SPI_MOSI;		// SPI Master output

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
	
	clk 		 = 1'b0;
	SPI_MISO 	 = 1'b0;
	rd_en 		 = 1'b0;
	wr_en 	 	 = 1'b0;
	//start_addr 	 = 8'h0;
	tx_wr_data 	 = 8'h0;
	sclk_divider = 8'h0;
	rst_n 		 = 1'b0;
	
	#100 
	rst_n 		 = 1'b1;
	
	@(negedge clk);
	for(patcount=0; patcount < PATNUM; patcount = patcount + 1) begin
		write_data;
		read_data;
		if(patcount < PATNUM)
			$display(patcount + 1);
	end
	
	$finish;
	
	/*#150
	tx_wr_data 	 = 8'hAA;
	rd_en 	 	 = 1'b0 ;
	wr_en	 	 = 1'b1 ;
	//start_addr	 = 8'h55;
	//state_init	 = 8'hAF;
	sclk_divider = 8'h1 ;
	
	#200
	rd_en 		 = 1'b0;
	wr_en	 	 = 1'b0;*/
	
	#(8550);
	$finish;
end

//================================================================
//  Write Data                         
//================================================================
task write_data; begin
	wr_en = 1'b1;
	rd_en = 1'b0;
	#100 wr_en = 1'b0;
	sclk_divider = 8'h1;
	a = $fscanf(pat_file, "%h", tx_wr_data);
	repeat(7'd64) @(negedge clk); // each data delay bits
end endtask

//================================================================
//  Read Data                         
//================================================================
task read_data; begin
	rd_en = 1'b1;
	wr_en = 1'b0;
	#100 rd_en = 1'b0;
	sclk_divider = 8'h1;
	repeat(7'd64) @(negedge clk);
end endtask

//================================================================
//  Slave Data                         
//================================================================
always #100 SPI_MISO = ~SPI_MISO;

endmodule