/*Synchronous and Asychronous DFF*/
//Synchronous DFF
/*module DFF(a, b, clk, reset);
	input [3:0] a;
	input clk, reset;
	output reg [3:0] b;
	
	always @(posedge clk) begin
		if(reset)
			b <= 4'b0000;
		else
			b <= a;
	end
endmodule*/

//Asychronous DFF
module DFF(a, b, clk, reset);
	input [3:0] a;
	input clk, reset;
	output reg [3:0] b;
	
	always @(posedge clk or posedge reset) begin
		if(reset)
			b <= 4'b0000;
		else
			b <= a;
	end
endmodule