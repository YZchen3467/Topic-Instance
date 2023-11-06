//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : I2C_Master_recive_TB.v
//   Module Name : I2C_Master_recive_TB
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns/10ps
`include "I2C_Master_recive_PAT.v"

`ifdef RTL
  `include "I2C_Master_recive.v"
`endif

module I2C_Master_recive_TB;

// common
wire clk;
wire rst_n;

// input
wire i_i2c_recv_en;
wire [6:0] i_device_addr;
wire [7:0] i_data_addr;

// output 
wire [7:0] o_read_data;
wire o_done_flag;
wire o_scl;
wire o_sda_mode;
wire o_ack_state;
wire [1:0] o_slave_state;

// inout
wire io_sda;

initial begin
	`ifdef RTL
		$dumpfile("I2C_Master_recv.vcd");
		$dumpvars();
	`endif
end

I2C_Master_recive u_i2c_recv_master
(
	.clk                    (clk 		             ),
	.rst_n 					(rst_n                   ),
	
	.i_i2c_recv_en 			(i_i2c_recv_en           ),
	.i_device_addr          (i_device_addr           ),        
	.i_data_addr 			(i_data_addr             ),
	
	// output
	.o_read_data 			(o_read_data             ),
	.o_done_flag 			(o_done_flag             ),
	.o_scl                  (o_scl                   ),
	.o_sda_mode             (o_sda_mode              ),
	.o_slave_state			(o_slave_state           ),
	
	// inout
	.io_sda					(io_sda		             )
);

I2C_Master_recive_PAT u_i2c_recv_master_pat
(
	.clk                    (clk 		             ),
	.rst_n					(rst_n                   ),
	
	.i_i2c_recv_en			(i_i2c_recv_en           ),
	.i_device_addr	        (i_device_addr           ),        
	.i_data_addr 			(i_data_addr             ),
	
	// output
	.o_read_data 			(o_read_data             ),
	.o_done_flag 			(o_done_flag             ),
	.o_scl                  (o_scl                   ),
	.o_sda_mode             (o_sda_mode              ),
	.o_slave_state			(o_slave_state           ),
	
	// inout
	.io_sda					(io_sda		             )
);

endmodule