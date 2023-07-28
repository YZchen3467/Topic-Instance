//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : SINGLEPORT_SRAM_SYN.v
//   Module Name : SINGLEPORT_SRAM_SYN
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module SINGLEPORT_SRAM_SYN #(
		parameter ADDR_WIDTH = 16, 			  // define addr width = 4
		parameter DATA_WIDTH = 8, 			  // define data width = 4
		parameter RAM_DEPTH = 1 << ADDR_WIDTH // define ram depth = 256
		)(
			// input
			clk,
			
			i_address,  // data_address
			i_cs,		// chip sel
			i_wr_en,	// write_en
			i_o_en,		// output_en
			
			// inout
			io_data		// data
		);
							
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
// input
input clk;
 
input [ADDR_WIDTH-1:0] i_address;
input i_cs;
input i_wr_en;
input i_o_en;

// inout
inout [DATA_WIDTH-1:0] io_data;

//================================================================
//  Wires & Registers
//================================================================
reg [DATA_WIDTH-1:0] r_data_out;
reg [DATA_WIDTH-1:0] r_mem [0:RAM_DEPTH-1];
reg r_o_en; // output enable register

//================================================================
//  Single mem rd/wr
//================================================================
always @(posedge clk) begin
	if(i_cs & i_wr_en) begin // write declaration
		r_mem [i_address] <= io_data;
	end
	else if(i_cs & !i_wr_en & i_o_en) begin
		r_data_out <= r_mem[i_address];
	end
	else begin
		r_mem[i_address] <= r_mem[i_address];
		r_data_out <= r_data_out;
	end
end
	
assign io_data = (i_cs & !i_wr_en & i_o_en) ? r_data_out:{DATA_WIDTH{1'bz}};
	
endmodule