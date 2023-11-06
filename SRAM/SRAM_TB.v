//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : SRAM_TB.v
//   Module Name : SRAM_TB
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns / 1ps

`include "SINGLEPORT_SRAM_SYN.v"

module SRAM_TB;
reg [15:0] addr;
reg clk;
reg cs;
reg o_en;
reg wr_en;
wire [7:0] data; // datain/out

reg [7:0] din;

initial begin
	$dumpfile("SRAM.vcd");
	$dumpvars();
end

//================================================================
//  clock
//================================================================
initial clk = 0;
always #10 clk = ~clk;

assign data = (cs & wr_en) ? din:8'bzzzz_zzzz;

initial begin
	addr    = 4'b0000;
	din     = 8'd1;
	wr_en   = 1'b0;
	o_en    = 1'b1;
	cs      = 1'b1;
	
	#20 // read
	repeat(65536) #20 addr = addr + 1'b1;
	
	#20 // write
	wr_en = 1'b1;
	repeat(65536) begin
		#20 addr = addr - 1'b1;
		din = din + 1'b1;
	end
	
	#50 $finish;
	
end

// instantation
SINGLEPORT_SRAM_SYN sram_inst(
			.clk        (clk                     ),
			
			.i_address  (addr                    ),  // data_address
			.i_cs		(cs                      ),  // chip sel
			.i_wr_en 	(wr_en                   ),  // write_en
			.i_o_en 	(o_en                    ),	 // output_en
			
			// inout
			.io_data    (data                    )	 // data
);

endmodule