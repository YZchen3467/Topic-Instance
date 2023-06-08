//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : baudrate_gen_PAT.v
//   Module Name : baudrate_gen_PAT
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`ifdef RTL
	`timescale 1ns/10ps
`endif

module baudrate_gen_PAT( // output
					 clk,
					 rst_n,
					 I_baudrate_tx_clk_en,
					 I_baudrate_rx_clk_en,
					 
					 // input
					 O_baudrate_tx_clk,
					 O_baudrate_rx_clk
					 );

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
output reg clk, rst_n;
output reg I_baudrate_tx_clk_en;
output reg I_baudrate_rx_clk_en;

input O_baudrate_tx_clk;
input O_baudrate_rx_clk;

//================================================================
//  clock
//================================================================
initial clk = 0;
always #10 clk = ~clk;

//================================================================
//  INITIAL                         
//================================================================
initial begin
	force clk = 0;
	I_baudrate_tx_clk_en = 1'b0;
	reset_task;
	
	#30
	I_baudrate_rx_clk_en = 1'b1;
	// I_baudrate_tx_clk_en = 1'b1;
	#(100_000_000);
	$finish;
	
end

//================================================================
//  reset_task       
//================================================================
task reset_task; begin
	#(0.5); rst_n = 1'b0;
	#(2.0);
	#(1.0); rst_n = 1;
	#(3.0); release clk;
end endtask

endmodule