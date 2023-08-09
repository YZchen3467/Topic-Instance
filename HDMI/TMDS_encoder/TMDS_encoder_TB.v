//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : TMDS_encoder_TB.v
//   Module Name : TMDS_encoder_TB
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns/10ps
`include "TMDS_encoder.v"

module TMDS_encoder_TB();

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
// INPUT
reg  clk; 					// system clk
reg  rst_n; 				// ststem rst, positive actived
reg  [7:0] i_din; 			// data input
reg  i_de;					// data enable
reg  i_c0, i_c1;			// input control bit

// OUTPUT
wire [9:0] o_dout;			// output data


//================================================================
//  Instantiate the module
//================================================================
TMDS_encoder uut (
    .clk			(clk			),
    .rst_n			(rst_n			),
    .i_din			(i_din			),
    .i_de			(i_de			),
    .i_c0			(i_c0			),
    .i_c1			(i_c1			),
    .o_dout			(o_dout			)
  );


//================================================================
//  Clock generation
//================================================================  
always #20 clk = ~clk;


//================================================================
//  Initial block
//================================================================
initial begin
	$dumpfile("TMDS_encoder.vcd");
	$dumpvars();
end

initial begin
    // Initialize inputs
	// initial setting
	force clk = 0;
	i_din = 8'b0;
	i_de = 0;
	i_c0 = 0;
	i_c1 = 0;
	
	reset_task;
	
    // Test case 1: Transmit position information
    #10;
    i_c0 = 0;
    i_c1 = 0;
	i_de = 1;
	
    i_din = 8'b1111_1000;
	
	repeat(100) @(negedge clk);
    #10;
    
    // Finish simulation
    $finish;
end

//================================================================
//  reset_task       
//================================================================
task reset_task; begin
	#(0.5); rst_n = 1'b0;
	#(2.0);
	#(1.0); rst_n = 1'b1;
	#(3.0); release clk;
end endtask

endmodule