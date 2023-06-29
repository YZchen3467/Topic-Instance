//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : I2C_Master_PAT.v
//   Module Name : I2C_Master_PAT
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`ifdef RTL
	`timescale 1ns/10ps
`endif

module I2C_Master_PAT( // output  
					clk,
					rst_n,
					
					i_i2c_en,
					i_device_addr,
					i_data_addr,
					i_write_data,
						
					// input
					o_done_flag,
					o_scl,
					o_sda_mode,
					
					// inout
					io_sda	
					);

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
// output 
output reg clk;
output reg rst_n;

output reg i_i2c_en;
output reg [6:0] i_device_addr;
output reg [7:0] i_data_addr;
output reg [7:0] i_write_data;

// input
input o_done_flag;
input o_scl;
input o_sda_mode;

// inout
inout wire io_sda;

//================================================================
//  parameters & integer
//================================================================
integer i, pat_file;
integer PATNUM, patcount;
integer write_in;

//================================================================
//  clock
//================================================================
initial clk = 0 ;
always #10 clk = ~clk ;

//================================================================
//  inout processing
//================================================================
assign io_sda = (o_sda_mode == 1'b1) ? 1'bz:1'b0; // if sda is input mode => sda_mode == 1'b0,
                                                  // input the zeor as ack response to master

//================================================================
//  initial
//================================================================
initial begin 
	pat_file = $fopen("pattern_gen.txt", "r");
	write_in = $fscanf(pat_file, "%d\n", PATNUM);

	// initial setting
	force clk = 0;
	reset_task;
	i_i2c_en = 0;
	
	// write_in
	@(negedge clk);
	for(patcount = 0; patcount < PATNUM; patcount = patcount + 1) begin
		write_in_task;
		$display("Patnum NO.%4d", patcount+1);
	end
	
	#(1_000);
	
	$finish;
end

//================================================================
//  reset_task       
//================================================================
task reset_task; begin
	#(0.5); rst_n = 1'b0;
	#(2.0);
	#(1.0); rst_n = 1'b1;
	#(3.0); release clk;
end endtask

//================================================================
//  device_addr_task       
//================================================================
task write_in_task; begin
	i_i2c_en = 1;
	write_in = $fscanf(pat_file, "%h %h %h\n", i_device_addr, i_data_addr,  i_write_data);
	while (o_done_flag != 1) begin
        @(negedge clk);
    end
    i_i2c_en = 0;
	repeat(1000) @(negedge clk);
end endtask

endmodule