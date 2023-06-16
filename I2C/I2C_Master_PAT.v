//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : I2C_Master_PAT.v
//   Module Name : I2C_Master_PAT
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`ifdef RTL
	`timescale 1ns/10ps
`endif

module I2C_Master_PAT( // output  
					clk,
					rst_n,
					
					i_i2c_en,
					i_device_addr,
					i_data_addr,
					i_write_data,
						
					// input
					o_done_flag,
					o_scl,
					
					// inout
					io_sda	
					);

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
//input 
output reg clk;
output reg rst_n;

output reg i_i2c_en;
output reg [6:0] i_device_addr;
output reg [7:0] i_data_addr;
output reg [7:0] i_write_data;

// output
input o_done_flag;
input o_scl;

// inout
inout io_sda;

//================================================================
//  integer / genvar / parameters
//================================================================


//================================================================
//  clock
//================================================================
initial clk = 0 ;
always #10 clk = ~clk ;

//================================================================
//  initial
//================================================================
initial begin 
	force clk = 0;
	reset_task;
	
	#(500_000)
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