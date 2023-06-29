//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : I2C_Master_TB.v
//   Module Name : I2C_Master_TB
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns/10ps
`include "I2C_Master_PAT.v"

`ifdef RTL
  `include "I2C_Master.v"
`endif

module I2C_Master_TB();

// common
wire clk;
wire rst_n;

// I2C Master
wire i_i2c_en;
wire io_sda;
wire o_sda_mode;

// I2C write_in 
wire [6:0] i_device_addr;
wire [7:0] i_data_addr;
wire [7:0] i_write_data;

initial begin
	`ifdef RTL
		$dumpfile("I2C_Master.vcd");
		$dumpvars();
	`endif
end



I2C_Master u_i2c_master
(
	.clk                   (clk                     ),
	.rst_n                 (rst_n                   ),
											        
	.i_i2c_en              (i_i2c_en                ),
	.i_device_addr         (i_device_addr           ),
	.i_data_addr           (i_data_addr             ),
	.i_write_data          (i_write_data            ),
											        
	// output                                        
	.o_done_flag           (o_done_flag             ),
	.o_scl                 (o_scl                   ),
	.o_sda_mode	           (o_sda_mode              ),	
	
	// inout                             
	.io_sda                (io_sda                  )
);

I2C_Master_PAT u_i2c_master_pat
(
	.clk                   (clk                     ),
	.rst_n                 (rst_n                   ),
											        
	.i_i2c_en              (i_i2c_en                ),
	.i_device_addr         (i_device_addr           ),
	.i_data_addr           (i_data_addr             ),
	.i_write_data          (i_write_data            ),
											        
	// output                                        
	.o_done_flag           (o_done_flag             ),
	.o_scl                 (                        ),
	.o_sda_mode	           (o_sda_mode              ),
	
	// inout
	.io_sda                (io_sda                  )
);

endmodule