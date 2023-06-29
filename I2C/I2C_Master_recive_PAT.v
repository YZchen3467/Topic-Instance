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
always @(negedge clk) begin
	if(o_sda_mode == 1'b0) begin
		case (o_slave_state)
			2'b00: r_io_sda <= 1'b0;  	// default sda_out from slave to master set to 0 
			2'b01: r_io_sda <= 1'b0;  	// Output 0 for ACK state
			2'b10: begin
				r_io_sda <= ~r_io_sda;
				repeat(495) @(negedge clk);
			end
			default: r_io_sda <= 1'b0;        // Default case, set to 0
		endcase
	end
end

assign io_sda = (o_sda_mode == 1'b1) ? 1'bz:r_io_sda;			
			
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
	r_data = 8'b0000_0000;
	
	
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
	write_in = $fscanf(pat_file, "%h %h %h\n", i_device_addr, i_data_addr, r_data);
	while (o_done_flag != 1) begin
        @(negedge clk);
    end
    i_i2c_recv_en = 0;
	repeat(1000) @(negedge clk);
end endtask

//================================================================
//  data_task       
//================================================================
/*task data_task; begin
	if(o_slave_state == 2'b10)begin
		if(o_scl == 1'b0)begin
			for(i=0; i<8; i=i+1)begin
				r_io_sda <= r_data[8-i];
				repeat(500) @(negedge clk);
			end
		end
	end	
end endtask*/

endmodule