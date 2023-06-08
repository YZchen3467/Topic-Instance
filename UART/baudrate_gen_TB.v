//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : baudrate_gen_TB.v
//   Module Name : baudrate_gen_TB
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns/10ps

`include "baudrate_gen_PAT.v"
`ifdef RTL
  `include "baudrate_gen.v"
`endif

module baudrate_gen_TB;

// input
wire clk;
wire rst_n;
wire I_baudrate_tx_clk_en;
wire I_baudrate_rx_clk_en;

// output
wire O_baudrate_tx_clk;
wire O_baudrate_rx_clk;

initial begin
	`ifdef RTL
		$dumpfile("baudrate_gen.vcd");
		$dumpvars();
	`endif
end

baudrate_gen u_baurate_gen(
			// input
			.clk(clk),
			.rst_n(rst_n),
			.I_baudrate_tx_clk_en(I_baudrate_tx_clk_en),
			.I_baudrate_rx_clk_en(I_baudrate_rx_clk_en),
			// ouput
			.O_baudrate_tx_clk(O_baudrate_tx_clk),
			.O_baudrate_rx_clk(O_baudrate_rx_clk)
);

baudrate_gen_PAT u_baurate_gen_PAT(
			// input
			.clk(clk),
			.rst_n(rst_n),
			.I_baudrate_tx_clk_en(I_baudrate_tx_clk_en),
			.I_baudrate_rx_clk_en(I_baudrate_rx_clk_en),
			// ouput
			.O_baudrate_tx_clk(O_baudrate_tx_clk),
			.O_baudrate_rx_clk(O_baudrate_rx_clk)
);

endmodule