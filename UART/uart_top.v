<<<<<<< HEAD
<<<<<<< HEAD
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : uart_top.v
//   Module Name : uart_top
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns/10ps
`include "uart_txd_PAT.v"

`ifdef RTL
  `include "uart_txd.v"
  `include "uart_rxd.v"
  `include "baudrate_gen.v"
`endif

module uart_top;

// common
wire clk;
wire rst_n;

// uart txd module
wire i_tx_start;
wire i_baudrate_tx_clk;
wire [7:0] i_data;

wire o_rs232_txd;
wire o_baudrate_tx_clk_en;
wire o_tx_done;

// uart rxd module
wire i_rx_start;
wire i_baudrate_rx_clk;
wire i_rs232_rxd;

wire [7:0] o_data;
wire o_baudrate_rx_clk_en;
wire o_rx_done;

// baudgen module
wire I_baudrate_tx_clk_en;
wire I_baudrate_rx_clk_en;

wire O_baudrate_tx_clk;
wire O_baudrate_rx_clk;

initial begin
	`ifdef RTL
		$dumpfile("uart_top.vcd");
		$dumpvars();
	`endif
end

//================================================================
//  uart txd module
//================================================================
uart_txd U_uart_txd
(
    .clk                  (clk                   ), // sys_clk
    .rst_n                (rst_n                 ), // sys_rst_n
    .i_tx_start           (i_tx_start            ), // tx_start_signal
    .i_baudrate_tx_clk    (O_baudrate_tx_clk     ), // baud_tx_clk
    .i_data               (i_data                ), // data_source
    .o_rs232_txd          (o_rs232_txd           ), // receieved data
    .o_baudrate_tx_clk_en (o_baudrate_tx_clk_en  ), // baud_tx_clk_en_signals
    .o_tx_done            (o_tx_done             )  // finsh_signals
);

uart_PAT u_uart_PAT
(
	.clk                  (clk                   ), // sys_clk
    .rst_n                (rst_n                 ), // sys_rst_n
    .i_tx_start           (i_tx_start            ), // tx_start_signal
    .i_baudrate_tx_clk    (                      ), // baud_tx_clk
    .i_data               (i_data                ), // data_source
    .o_rs232_txd          (o_rs232_txd           ), // receieved data
    .o_baudrate_tx_clk_en (o_baudrate_tx_clk_en  ), // baud_tx_clk_en_signals
    .o_tx_done            (o_tx_done             )  // finsh_signals
);

//================================================================
//  uart rxd module
//================================================================
uart_rxd U_uart_rxd
(
	.clk                  (clk                   ), // sys_clk
	.rst_n                (rst_n                 ), // sys_rst_n
	.i_rx_start           (1'b1                  ), // rx_start_signal
	.i_baudrate_rx_clk    (O_baudrate_rx_clk     ), // baud_rx_clk
	.i_rs232_rxd          (o_rs232_txd           ), // receieved data
	.o_data               (o_data                ), // output data
	.o_baudrate_rx_clk_en (o_baudrate_rx_clk_en  ), // baud_rx_clk_en_signals
	.o_rx_done            (o_rx_done             ) // rx_finish_signals
);

//================================================================
//  baud module
//================================================================
baudrate_gen U_baudrate_gen
(
    .clk                  (clk                  ), // sys_clk
    .rst_n                (rst_n                ), // sys_rst_n
    .I_baudrate_tx_clk_en (o_baudrate_tx_clk_en ), // tx_clk_en
    .I_baudrate_rx_clk_en (o_baudrate_rx_clk_en ), // rx_clk_en
    .O_baudrate_tx_clk    (O_baudrate_tx_clk    ), // tx_clk
    .O_baudrate_rx_clk    (O_baudrate_rx_clk    )  // rx_clk
);

=======
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : uart_top.v
//   Module Name : uart_top
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns/10ps
`include "uart_txd_PAT.v"

`ifdef RTL
  `include "uart_txd.v"
  `include "uart_rxd.v"
  `include "baudrate_gen.v"
`endif

module uart_top;

// common
wire clk;
wire rst_n;

// uart txd module
wire i_tx_start;
wire i_baudrate_tx_clk;
wire [7:0] i_data;

wire o_rs232_txd;
wire o_baudrate_tx_clk_en;
wire o_tx_done;

// uart rxd module
wire i_rx_start;
wire i_baudrate_rx_clk;
wire i_rs232_rxd;

wire [7:0] o_data;
wire o_baudrate_rx_clk_en;
wire o_rx_done;

// baudgen module
wire I_baudrate_tx_clk_en;
wire I_baudrate_rx_clk_en;

wire O_baudrate_tx_clk;
wire O_baudrate_rx_clk;

initial begin
	`ifdef RTL
		$dumpfile("uart_top.vcd");
		$dumpvars();
	`endif
end

//================================================================
//  uart txd module
//================================================================
uart_txd U_uart_txd
(
    .clk                  (clk                   ), // sys_clk
    .rst_n                (rst_n                 ), // sys_rst_n
    .i_tx_start           (i_tx_start            ), // tx_start_signal
    .i_baudrate_tx_clk    (O_baudrate_tx_clk     ), // baud_tx_clk
    .i_data               (i_data                ), // data_source
    .o_rs232_txd          (o_rs232_txd           ), // receieved data
    .o_baudrate_tx_clk_en (o_baudrate_tx_clk_en  ), // baud_tx_clk_en_signals
    .o_tx_done            (o_tx_done             )  // finsh_signals
);

uart_PAT u_uart_PAT
(
	.clk                  (clk                   ), // sys_clk
    .rst_n                (rst_n                 ), // sys_rst_n
    .i_tx_start           (i_tx_start            ), // tx_start_signal
    .i_baudrate_tx_clk    (                      ), // baud_tx_clk
    .i_data               (i_data                ), // data_source
    .o_rs232_txd          (o_rs232_txd           ), // receieved data
    .o_baudrate_tx_clk_en (o_baudrate_tx_clk_en  ), // baud_tx_clk_en_signals
    .o_tx_done            (o_tx_done             )  // finsh_signals
);

//================================================================
//  uart rxd module
//================================================================
uart_rxd U_uart_rxd
(
	.clk                  (clk                   ), // sys_clk
	.rst_n                (rst_n                 ), // sys_rst_n
	.i_rx_start           (1'b1                  ), // rx_start_signal
	.i_baudrate_rx_clk    (O_baudrate_rx_clk     ), // baud_rx_clk
	.i_rs232_rxd          (o_rs232_txd           ), // receieved data
	.o_data               (o_data                ), // output data
	.o_baudrate_rx_clk_en (o_baudrate_rx_clk_en  ), // baud_rx_clk_en_signals
	.o_rx_done            (o_rx_done             ) // rx_finish_signals
);

//================================================================
//  baud module
//================================================================
baudrate_gen U_baudrate_gen
(
    .clk                  (clk                  ), // sys_clk
    .rst_n                (rst_n                ), // sys_rst_n
    .I_baudrate_tx_clk_en (o_baudrate_tx_clk_en ), // tx_clk_en
    .I_baudrate_rx_clk_en (o_baudrate_rx_clk_en ), // rx_clk_en
    .O_baudrate_tx_clk    (O_baudrate_tx_clk    ), // tx_clk
    .O_baudrate_rx_clk    (O_baudrate_rx_clk    )  // rx_clk
);

>>>>>>> 17b668c496893641e9891cc2cdfa404909e40e7e
=======
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : uart_top.v
//   Module Name : uart_top
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns/10ps
`include "uart_txd_PAT.v"

`ifdef RTL
  `include "uart_txd.v"
  `include "uart_rxd.v"
  `include "baudrate_gen.v"
`endif

module uart_top;

// common
wire clk;
wire rst_n;

// uart txd module
wire i_tx_start;
wire i_baudrate_tx_clk;
wire [7:0] i_data;

wire o_rs232_txd;
wire o_baudrate_tx_clk_en;
wire o_tx_done;

// uart rxd module
wire i_rx_start;
wire i_baudrate_rx_clk;
wire i_rs232_rxd;

wire [7:0] o_data;
wire o_baudrate_rx_clk_en;
wire o_rx_done;

// baudgen module
wire I_baudrate_tx_clk_en;
wire I_baudrate_rx_clk_en;

wire O_baudrate_tx_clk;
wire O_baudrate_rx_clk;

initial begin
	`ifdef RTL
		$dumpfile("uart_top.vcd");
		$dumpvars();
	`endif
end

//================================================================
//  uart txd module
//================================================================
uart_txd U_uart_txd
(
    .clk                  (clk                   ), // sys_clk
    .rst_n                (rst_n                 ), // sys_rst_n
    .i_tx_start           (i_tx_start            ), // tx_start_signal
    .i_baudrate_tx_clk    (O_baudrate_tx_clk     ), // baud_tx_clk
    .i_data               (i_data                ), // data_source
    .o_rs232_txd          (o_rs232_txd           ), // receieved data
    .o_baudrate_tx_clk_en (o_baudrate_tx_clk_en  ), // baud_tx_clk_en_signals
    .o_tx_done            (o_tx_done             )  // finsh_signals
);

uart_PAT u_uart_PAT
(
	.clk                  (clk                   ), // sys_clk
    .rst_n                (rst_n                 ), // sys_rst_n
    .i_tx_start           (i_tx_start            ), // tx_start_signal
    .i_baudrate_tx_clk    (                      ), // baud_tx_clk
    .i_data               (i_data                ), // data_source
    .o_rs232_txd          (o_rs232_txd           ), // receieved data
    .o_baudrate_tx_clk_en (o_baudrate_tx_clk_en  ), // baud_tx_clk_en_signals
    .o_tx_done            (o_tx_done             )  // finsh_signals
);

//================================================================
//  uart rxd module
//================================================================
uart_rxd U_uart_rxd
(
	.clk                  (clk                   ), // sys_clk
	.rst_n                (rst_n                 ), // sys_rst_n
	.i_rx_start           (1'b1                  ), // rx_start_signal
	.i_baudrate_rx_clk    (O_baudrate_rx_clk     ), // baud_rx_clk
	.i_rs232_rxd          (o_rs232_txd           ), // receieved data
	.o_data               (o_data                ), // output data
	.o_baudrate_rx_clk_en (o_baudrate_rx_clk_en  ), // baud_rx_clk_en_signals
	.o_rx_done            (o_rx_done             ) // rx_finish_signals
);

//================================================================
//  baud module
//================================================================
baudrate_gen U_baudrate_gen
(
    .clk                  (clk                  ), // sys_clk
    .rst_n                (rst_n                ), // sys_rst_n
    .I_baudrate_tx_clk_en (o_baudrate_tx_clk_en ), // tx_clk_en
    .I_baudrate_rx_clk_en (o_baudrate_rx_clk_en ), // rx_clk_en
    .O_baudrate_tx_clk    (O_baudrate_tx_clk    ), // tx_clk
    .O_baudrate_rx_clk    (O_baudrate_rx_clk    )  // rx_clk
);

>>>>>>> 39059d7608a97f01c32b431de6bb75b2ca74f4cd
endmodule