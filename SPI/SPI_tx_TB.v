//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : SPI_tx_TB.v
//   Module Name : SPI_tx_TB
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`timescale 1ns/10ps

`include "SPI_tx_PATTERN.v"
`ifdef RTL
  `include "SPI_tx.v"
`endif

module SPI_tx_TB;

//================================================================
//  Wires                         
//================================================================	
// input 			
wire clk;
wire rst_n;

wire sclk_divider; 
wire wr_en;
wire [7:0] tx_wr_data;

// output
wire wr_done;

//SPI
wire SPI_miso;
wire SPI_mosi;
wire SPI_sclk;
wire SPI_csn;

initial begin
	`ifdef RTL
		$dumpfile("SPI_tx.vcd");
		$dumpvars();
	`endif
end

SPI_tx u_SPI_tx
		(
		.clk         	(clk         ),		
		.rst_n       	(rst_n       ),		
		
		.sclk_divider	(sclk_divider),		
		.wr_en    	 	(wr_en       ),				
		.tx_wr_data  	(tx_wr_data  ),			
				
		.wr_done     	(wr_done     ),							
					
		.SPI_miso    	(SPI_miso    ), 		
		.SPI_mosi    	(SPI_mosi    ),		
		.SPI_sclk    	(SPI_sclk    ),		
		.SPI_csn     	(SPI_csn     )		
		);
		
SPI_tx_PATTERN u_SPI_tx_pat
		(
		.clk         	(clk         ),
		.rst_n       	(rst_n       ),
		
		.sclk_divider	(sclk_divider),
		.wr_en    	 	(wr_en       ),
		.tx_wr_data  	(tx_wr_data  ),
				
		.wr_done     	(wr_done     ),
					
		.SPI_miso    	(SPI_miso    ),
		.SPI_mosi    	(SPI_mosi    ),
		.SPI_sclk    	(SPI_sclk    ),
		.SPI_csn     	(SPI_csn     )	
		);
		
endmodule