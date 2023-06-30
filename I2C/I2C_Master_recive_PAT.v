//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : I2C_Master_recive_PAT.v
//   Module Name : I2C_Master_recive_PAT
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`ifdef RTL
	`timescale 1ns/10ps
`endif

module I2C_Master_recive_PAT(
			   // output
			   clk,
			   rst_n,
			   
			   i_i2c_recv_en,
			   i_device_addr,
			   i_data_addr,
				
			   // input
			   o_read_data,
			   o_done_flag,
			   o_scl,
			   o_sda_mode,
			   o_slave_state,
			   
			   // inout
			   io_sda
               );

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
output reg clk;                   // 50MHz sys_clk
output reg rst_n;                     
								 
output reg i_i2c_recv_en;         // i2c_master enable
output reg [6:0] i_device_addr;	  // device address
output reg [7:0] i_data_addr;     // data address 
								 
// output
input [7:0] o_read_data;    	  // recived data                        
input o_done_flag;          	  // done_flag
input o_scl;                      // i2c clk
input o_sda_mode;           	  // sda mode => 1 output signal / 0 input signal
input [1:0] o_slave_state;		  // ack_state check

// inout
inout wire io_sda;

//================================================================
//  Wires & Registers
//================================================================
reg r_io_sda;
reg [7:0] r_data;
reg r_io_sda_delay;
reg [2:0] bit_index;

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

assign io_sda = (o_sda_mode == 1'b1) ? 1'bz:(o_slave_state == 2'b01 ? 1'b0:r_io_sda );		
			
//================================================================
//  initial
//================================================================
initial begin 
	pat_file = $fopen("pattern_gen.txt", "r");
	write_in = $fscanf(pat_file, "%d\n", PATNUM);

	// initial setting
	force clk = 0;
	reset_task;
	i_i2c_recv_en = 0;
	r_io_sda = 1'b0;
	
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
	i_i2c_recv_en = 1;
	bit_index = 0;
	write_in = $fscanf(pat_file, "%h %h %h\n", i_device_addr, i_data_addr, r_data);
	while (o_done_flag != 1) begin
        @(negedge clk);
		if (i_i2c_recv_en && o_slave_state == 2'b10 && o_scl == 1'b0) begin
			if (bit_index == 0)
				r_io_sda <= r_data[7];
			else if (bit_index == 1)
				r_io_sda <= r_data[6];
			else if (bit_index == 2)
				r_io_sda <= r_data[5];
			else if (bit_index == 3)
				r_io_sda <= r_data[4];
			else if (bit_index == 4)
				r_io_sda <= r_data[3];
			else if (bit_index == 5)
				r_io_sda <= r_data[2];
			else if (bit_index == 6)
				r_io_sda <= r_data[1];
			else if (bit_index == 7)
				r_io_sda <= r_data[0];
			
			repeat(250) @(negedge clk);
			bit_index = bit_index + 1'b1;
			if (bit_index > 7) begin
				bit_index = 3'd0;
			end
		end
    end
    i_i2c_recv_en = 0;
	repeat(1000) @(negedge clk);
	
end endtask

endmodule