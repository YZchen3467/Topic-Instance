//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : DUALPORT_SRAM_SYN.v
//   Module Name : DUALPORT_SRAM_SYN
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module DUALPORT_SRAM_SYN #( parameter ADDR_WIDTH = 4 ,
							parameter DATA_WIDTH = 8 ,
							parameter RAM_WIDTH  = 16,
							)(
			// input
			clk,
			rsr_n,
			
			i_cs,		  // chip sel
			i_address_r,  // readdata_address
			i_address_w	  // writedata_adress
			i_rd_en,	  // read_en
			i_wr_en,	  // write_en
			
			// port
			i_write_data  // wirte_in data
			o_read_data	  // read_out data
							);
							
integer i;


endmodule