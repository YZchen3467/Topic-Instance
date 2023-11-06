`timescale 1ns/10ps

//`include "tdm_deserializer.v"

module test_tdm_deserializer;

	reg [159:0] mem = { 32'h555555FA, 32'h555555FB, 32'h555555FC, 32'h555555FE,32'h555555FF};
	reg reset, fsync, data, clock;

	wire ready;
	wire [31:0] channel0;
	wire [31:0] channel1;
	wire [31:0] channel2;
	wire [31:0] channel3;
	wire [31:0] channel4;

	integer i, j;

	initial begin
		for (i=0; i < 5; i = i + 1) begin
			for (j=1; j < 6; j = j + 1) begin
				mem[j-1] = { 28'h555555A, $realtobits(j) };
			end
		end		
		$monitor ("Starting testbench...");
		$dumpfile("rawwaves_testrun.vcd");
		$dumpvars(0);
		
		clock = 0;
		reset = 0;
		fsync = 0;
		#5  reset = 1;
		#10 reset = 0;
		fsync = 1; 
		#1  fsync = 0;
		for (i=0; i < 160; i = i + 1) begin
			#2 data = mem[i];
		end
		$finish;
	end

	always begin
		#1 clock = !clock;
	end

	tdm_deserializer deserializer(
		.clock	   (clock),
		.reset	   (reset),
		.tdm_data  (data),
		.tdm_sync  (fsync),
		.tdm_clk   (clock),
		.word_ready(ready),
		.ch0	   (channel0),
		.ch1	   (channel1),
		.ch2	   (channel2),
		.ch3	   (channel3),
		.ch4	   (channel4)	
	);

endmodule
