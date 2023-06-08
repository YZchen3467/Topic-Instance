/*DFF tb*/
`timescale 1ns/1ps
module DFF_tb();
	reg [3:0] A;
	wire [3:0] B;
	reg CLK, RESET;
	
	DFF dff(.a(A), .b(B), .clk(CLK), .reset(RESET));
	
	always #5 CLK = ~CLK;
	initial CLK = 1'b0;
	
	initial begin
		$dumpfile("DFF.vcd");
		$dumpvars;
		#0 RESET = 1'b1;
		#10 RESET = 1'b0;
		#0 A = 4'b1001;
		#90 $finish;
	end
	
endmodule