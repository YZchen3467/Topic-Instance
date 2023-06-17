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
					o_sda_mode,
					
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
input o_sda_mode;

// inout
inout wire io_sda;

//================================================================
//  clock
//================================================================
initial clk = 0 ;
always #10 clk = ~clk ;

//================================================================
//  inout processing
//================================================================
assign io_sda = (o_sda_mode == 1'b1) ? 1'bz:1'b0; // if sda is input mode => sda_mode == 1'b0,
                                                  // input the zeor as ack response to master

//================================================================
//  initial
//================================================================
initial begin 
	force clk = 0;
	reset_task;
	i_i2c_en = 1'b1;
	
	#(1_000_000);
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
