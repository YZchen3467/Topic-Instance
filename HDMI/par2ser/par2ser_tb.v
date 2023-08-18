//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : par2ser_tb.v
//   Module Name : par2ser_tb
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns/10ps
`include "par2ser.v"

module par2ser_tb;
reg 	  clk;
reg [9:0] i_par_data;

wire      o_ser_data_p;
wire      o_ser_data_n;


//================================================================
//  Clock gen                         
//================================================================
always #10 clk = ~clk;


initial begin
	$dumpfile("par2ser.vcd");
	$dumpvars();
end


initial begin
	clk = 1'b0;
	#220	$finish;
		

end



par2ser uut(
		.clk_5x   			(clk					),
		.i_par_data			(10'b11010_01100		),
		.o_ser_data_p   	(o_ser_data_p			),
		.o_ser_data_n		(o_ser_data_n			)
		);



endmodule