//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : uart_tx_top.v
//   Module Name : uart_tx_top
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns/10ps
`include "baudrate_gen_PAT.v"
`include "uart_PAT.v"

`ifdef RTL
  `include "uart_txd.v"
  `include "baudrate_gen.v"
`endif


module uart_tx_top;

// common
wire clk;
wire rst_n;

// uart module
wire i_tx_start;
wire i_baudrate_tx_clk;
wire [7:0] i_data;

wire o_rs232_txd;
wire o_baudrate_tx_clk_en;
wire o_tx_done;

// baudgen module
wire I_baudrate_tx_clk_en;
wire I_baudrate_rx_clk_en;

wire O_baudrate_tx_clk;
wire O_baudrate_rx_clk;

initial begin
	`ifdef RTL
		$dumpfile("uart_tx_top.vcd");
		$dumpvars();
	`endif
end

//================================================================
//  uart module
//================================================================
uart_txd U_uart_txd
(
    .clk                  (clk                   ), // sys_clk
    .rst_n                (rst_n                 ), // sys_rst_n
    .i_tx_start           (i_tx_start            ), // start_signal
    .i_baudrate_tx_clk    (O_baudrate_tx_clk     ), // baud_tx_clk
    .i_data               (i_data                ), // data_source
    .o_rs232_txd          (o_rs232_txd           ), // receieve data
    .o_baudrate_tx_clk_en (o_baudrate_tx_clk_en  ), // baud_tx_clk_en_signals
    .o_tx_done            (o_tx_done             )  // finsh_signals
);

uart_PAT u_uart_PAT(
	.clk                  (clk                   ), // sys_clk
    .rst_n                (rst_n                 ), // sys_rst_n
    .i_tx_start           (i_tx_start            ), // start_signal
    .i_baudrate_tx_clk    (                      ), // baud_tx_clk
    .i_data               (i_data                ), // data_source
    .o_rs232_txd          (o_rs232_txd           ), // receieve data
    .o_baudrate_tx_clk_en (o_baudrate_tx_clk_en  ), // baud_tx_clk_en_signals
    .o_tx_done            (o_tx_done             )  // finsh_signals
);

//================================================================
//  baud module
//================================================================
baudrate_gen U_baudrate_gen
(
    .clk                  (clk                  ), // sys_clk
    .rst_n                (rst_n                ), // sys_rst_n
    .I_baudrate_tx_clk_en (o_baudrate_tx_clk_en ), // tx_clk_en
    .I_baudrate_rx_clk_en (                     ), // rx_clk_en
    .O_baudrate_tx_clk    (O_baudrate_tx_clk    ), // tx_clk
    .O_baudrate_rx_clk    (                     )  // rx_clk
);

/*baudrate_gen_PAT u_baurate_gen_PAT(
	.clk                  (clk                 ),
	.rst_n                (rst_n               ),
	.I_baudrate_tx_clk_en (o_baudrate_tx_clk_en),
	.I_baudrate_rx_clk_en (                    ),
	.O_baudrate_tx_clk    (O_baudrate_tx_clk   ),
	.O_baudrate_rx_clk    (                    )
);*/

endmodule
