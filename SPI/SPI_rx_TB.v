//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : SPI_rx_TB.v
//   Module Name : SPI_rx_TB
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`timescale 1ns/10ps

`include "SPI_rx_PATTERN.v"
`ifdef RTL
  `include "SPI_rx.v"
`endif

module SPI_rx_TB;

//================================================================
//  Wires                         
//================================================================	
// input 			
wire clk;
wire rst_n;

wire sclk_divider; 
wire rd_en;
wire [7:0] tx_wr_data;

// output
wire rd_done;
wire [7:0] rd_data;

//SPI
wire SPI_miso;
wire SPI_mosi;
wire SPI_sclk;
wire SPI_csn;

initial begin
	`ifdef RTL
		$dumpfile("SPI_rx.vcd");
		$dumpvars();
	`endif
end

SPI_rx u_SPI_rx
		(
		.clk         	(clk         ),		
		.rst_n       	(rst_n       ),		
		
		.sclk_divider	(sclk_divider),		
		.rd_en    	 	(rd_en       ),				
		.tx_wr_data  	(            ),			
				
		.rd_done     	(rd_done     ),
		.rd_data        (rd_data     ),
					
		.SPI_miso    	(SPI_miso    ), 		
		.SPI_mosi    	(SPI_mosi    ),		
		.SPI_sclk    	(SPI_sclk    ),		
		.SPI_csn     	(SPI_csn     )		
		);
		
SPI_rx_PATTERN u_SPI_rx_pat
		(
		.clk         	(clk         ),
		.rst_n       	(rst_n       ),
		
		.sclk_divider	(sclk_divider),
		.rd_en    	 	(rd_en       ),
		.tx_wr_data  	(            ),
				
		.rd_done     	(rd_done     ),
		.rd_data        (rd_data     ),
					
		.SPI_miso    	(SPI_miso    ),
		.SPI_mosi    	(SPI_mosi    ),
		.SPI_sclk    	(SPI_sclk    ),
		.SPI_csn     	(SPI_csn     )	
		);
		
endmodule