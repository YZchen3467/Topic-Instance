//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : SPI_Master_TB.v
//   Module Name : SPI_Master_TB
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns/10ps

`include "SPI_Master_PATTERN.v"
`ifdef RTL
  `include "SPI_Master.v"
`endif

module SPI_Master_TB;

// INPUT
wire clk; 					// System clk
wire rst_n; 				// System reset, active low
wire [7:0] sclk_divider; 	// SPI clk control / divid
wire wr_en;					// Write enable
wire rd_en;					// Read enable
/*wire [7:0] start_addr;		 Write / Read Start address*/
/*wire [7:0] state_init;		 slaver state initial*/
wire [7:0] tx_wr_data;		// TX Write Data
wire SPI_MISO;				// SPI Master input

// OUTPUT
wire wr_finish;		// Write finish
wire rd_finish;		// Read finish
wire rx_rd_data;	// RX Read Data
wire SPI_SCLK;		// SPI CLK
wire SPI_CSN; 		// SPI chip sel
wire SPI_MOSI;		// SPI Master output

initial begin
	`ifdef RTL
		$dumpfile("SPI_Master.vcd");
		$dumpvars();
	`endif
end

SPI_Master u_SPI_Master(
	.clk         (clk         ),    // System Clock.
    .rst_n       (rst_n       ),    // System Reset. Low Active 
    .sclk_divider(sclk_divider),    // SPI Clock Control / Divid
    .wr_en    	 (wr_en       ),    // Write  enable 
    .rd_en   	 (rd_en       ),    // Read   enable  

    .wr_finish   (wr_finish   ),    // Write  Finish 
    .rd_finish   (rd_finish   ),    // Read   Finish

    /*.start_addr  (start_addr  ),     Write / Read Start Address*/
    /*.state_init  (state_init  ),     slaver state initial*/  
    .tx_wr_data  (tx_wr_data  ),    // Tx Write Data
    .rx_rd_data  (rx_rd_data  ),    // Rx Read Data

    .SPI_SCLK    (SPI_SCLK    ),    // SPI Clock 
    .SPI_CSN     (SPI_CSN     ),    // SPI Chip Select 
    .SPI_MOSI    (SPI_MOSI    ),    // SPI Master Output 
    .SPI_MISO    (SPI_MISO    )     // SPI Master Input
);

SPI_Master_PATTERN u_SPI_Master_PAEETRN(
	.clk         (clk         ),    // System Clock.
    .rst_n       (rst_n       ),    // System Reset. Low Active 
    .sclk_divider(sclk_divider),    // SPI Clock Control / Divid
    .wr_en    	 (wr_en       ),    // Write  enable 
    .rd_en    	 (rd_en       ),    // Read   enable  

    .wr_finish   (wr_finish   ),    // Write  Finish 
    .rd_finish   (rd_finish   ),    // Read   Finish

    /*.start_addr  (start_addr  ),     Write / Read Start Address*/
    /*.state_init  (state_init  ),     slaver state initial*/  
    .tx_wr_data  (tx_wr_data  ),    // Tx Write Data
    .rx_rd_data  (rx_rd_data  ),    // Rx Read Data

    .SPI_SCLK    (SPI_SCLK    ),    // SPI Clock 
    .SPI_CSN     (SPI_CSN     ),    // SPI Chip Select 
    .SPI_MOSI    (SPI_MOSI    ),    // SPI Master Output 
    .SPI_MISO    (SPI_MISO    )     // SPI Master Input
);

endmodule