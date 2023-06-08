<<<<<<< HEAD:Verilog instance/UART/uart_txd_PAT.v
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : uart_PAT.v
//   Module Name : uart_PAT
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`ifdef RTL
	`timescale 1ns/10ps
`endif

module uart_PAT( // output
				clk,
				rst_n,
				i_tx_start,
				i_baudrate_tx_clk,
				i_data,
				
				// input
				o_rs232_txd,
				o_baudrate_tx_clk_en,
				o_tx_done
				);

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
output reg clk;					// sys_clk
output reg rst_n;			    // sys_rst_n
output reg i_tx_start;			// tx signal start enable
output reg i_baudrate_tx_clk;	// tx baud clk
output reg [7:0] i_data;		// transmission data

input o_rs232_txd;				// 
input o_baudrate_tx_clk_en;		// tx baud clk enable
input o_tx_done;				// data transmission done signal

//================================================================
//  Wires & Registers
//================================================================
reg [31:0] f_cnt;

//================================================================
//  parameters & integer
//================================================================
integer PATNUM;
integer patcount;
integer pat_file, a;
integer i;

//================================================================
//  clock
//================================================================
initial clk = 0;
always #10 clk = ~clk;

//================================================================
//  INITIAL                         
//================================================================
initial begin
	pat_file = $fopen("pattern.txt", "r");
	a = $fscanf(pat_file, "%d\n", PATNUM);
	force clk = 0;
	i_tx_start = 1'b0;
	i_data = 8'd0;
	
	reset_task;
	
	@(negedge clk);
	for(patcount=0; patcount < PATNUM; patcount = patcount + 1) begin
		write_data;
		i_tx_start = 1'b0;
		if(patcount < PATNUM)
			$display(patcount + 1);
	end
	#(100_000)
	$finish;
	
end

//================================================================
//  Write Data                         
//================================================================
task write_data; begin
	for(f_cnt=0; f_cnt<31'd5000; f_cnt=f_cnt+1) begin
		i_tx_start = 1'b0;
		@(negedge clk);
	end
	// f_cnt = 1'b0;
	a = $fscanf(pat_file, "%h", i_data);
	i_tx_start = 1'b1;
	@(negedge clk);
	
	/*if(o_baudrate_tx_clk_en == 1'b1 && o_rs232_txd == 1'b0) begin
		$display ("--------------------------------------------------");
        $display ("                      FAIL!                       ");
        $display ("--------------------------------------------------");
		a = $fscanf(pat_file, "%h", i_data);		
	end*/
end endtask
			
//================================================================
//  reset_task       
//================================================================
task reset_task; begin
	#(0.5); rst_n = 1'b0;
	#(2.0);
	#(1.0); rst_n = 1'b1;
	#(3.0); release clk;
end endtask

endmodule
=======
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : uart_PAT.v
//   Module Name : uart_PAT
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`ifdef RTL
	`timescale 1ns/10ps
`endif

module uart_PAT( // output
				clk,
				rst_n,
				i_tx_start,
				i_baudrate_tx_clk,
				i_data,
				
				// input
				o_rs232_txd,
				o_baudrate_tx_clk_en,
				o_tx_done
				);

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
output reg clk;					// sys_clk
output reg rst_n;			    // sys_rst_n
output reg i_tx_start;			// tx signal start enable
output reg i_baudrate_tx_clk;	// tx baud clk
output reg [7:0] i_data;		// transmission data

input o_rs232_txd;				// 
input o_baudrate_tx_clk_en;		// tx baud clk enable
input o_tx_done;				// data transmission done signal

//================================================================
//  Wires & Registers
//================================================================
reg [31:0] f_cnt;

//================================================================
//  parameters & integer
//================================================================
integer PATNUM;
integer patcount;
integer pat_file, a;
integer i;

//================================================================
//  clock
//================================================================
initial clk = 0;
always #10 clk = ~clk;

//================================================================
//  INITIAL                         
//================================================================
initial begin
	pat_file = $fopen("pattern.txt", "r");
	a = $fscanf(pat_file, "%d\n", PATNUM);
	force clk = 0;
	i_tx_start = 1'b0;
	i_data = 8'd0;
	
	reset_task;
	
	@(negedge clk);
	for(patcount=0; patcount < PATNUM; patcount = patcount + 1) begin
		write_data;
		i_tx_start = 1'b0;
		if(patcount < PATNUM)
			$display(patcount + 1);
	end
	#(100_000)
	$finish;
	
end

//================================================================
//  Write Data                         
//================================================================
task write_data; begin
	for(f_cnt=0; f_cnt<31'd5000; f_cnt=f_cnt+1) begin
		i_tx_start = 1'b0;
		@(negedge clk);
	end
	// f_cnt = 1'b0;
	a = $fscanf(pat_file, "%h", i_data);
	i_tx_start = 1'b1;
	@(negedge clk);
	
	/*if(o_baudrate_tx_clk_en == 1'b1 && o_rs232_txd == 1'b0) begin
		$display ("--------------------------------------------------");
        $display ("                      FAIL!                       ");
        $display ("--------------------------------------------------");
		a = $fscanf(pat_file, "%h", i_data);		
	end*/
end endtask
			
//================================================================
//  reset_task       
//================================================================
task reset_task; begin
	#(0.5); rst_n = 1'b0;
	#(2.0);
	#(1.0); rst_n = 1'b1;
	#(3.0); release clk;
end endtask

endmodule
>>>>>>> 17b668c496893641e9891cc2cdfa404909e40e7e:Verilog instance/UART/uart_PAT.v
