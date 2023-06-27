//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : I2C_Master_recive_PAT.v
//   Module Name : I2C_Master_recive_PAT
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module I2C_Master_recive_PAT(
			   // input
			   clk,
			   rst_n,
			   
			   i_i2c_recv_en,
			   i_device_addr,
			   i_data_addr,
				
			   // output
			   o_read_data,
			   o_done_flag,
			   o_scl,
			   o_sda_mode,
			   
			   // inout
			   io_sda
               );
endmodule