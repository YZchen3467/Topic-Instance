//counter
module counter(updown, load, data, count, clk, reset);

	input clk, reset, load, updown,
	input [3:0] data;
	output reg [3:0] count;
	
	always @(posedge clk)begin
		if(reset)
			count <= 3'b0;
		else if(load) //load the counter with data value
			count <= data;
		else if(updown) //count up
			count <= count + 1'b1;
		else
			count <= count - 1'b1;
	end

endmodule