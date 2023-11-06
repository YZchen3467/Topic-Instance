//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : hdmi_ctrl_tb.v
//   Module Name : hdmi_ctrl_tb
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns/10ps
`include "hdmi_ctrl.v"

module hdmi_ctrl_tb;

// input
reg 	clk_1x;
reg 	clk_5x;
reg 	sys_rst_n;
	
reg [7:0] rgb_red;
// reg [7:0] rgb_green;
// reg [7:0] rgb_blue;	
reg 	hsync;
reg 	vsync;
reg 	de;

// output
wire	hdmi_clk_p; 
wire    hdmi_clk_n;
wire    hdmi_r_p;
wire    hdmi_r_n;
// wire 	hdmi_g_p;
// wire 	hdmi_g_n;
// wire 	hdmi_b_p;
// wire 	hdmi_b_n;

//================================================================
//  inst                         
//================================================================
hdmi_ctrl hdmi_u(
			// clk
			.clk_1x			(clk_1x				),
			.clk_5x			(clk_5x				),
			.sys_rst_n		(sys_rst_n			),
			
			.rgb_red		(rgb_red			),
			// .rgb_green	(rgb_green			),
			// .rgb_blue	(rgb_blue			),
			.hsync			(hsync				),
			.vsync			(vsync				),
			.de				(de					),
			
			
			// output
			.hdmi_clk_p		( 					),
			.hdmi_clk_n		( 					),
			.hdmi_r_p		(hdmi_r_p			),
			.hdmi_r_n		(hdmi_r_n			)
			// .hdmi_g_p	(hdmi_g_p			),
			// .hdmi_g_n	(hdmi_g_n			),
            // .hdmi_b_p	(hdmi_b_p			),
			// .hdmi_b_n	(hdmi_b_n			)

);


//================================================================
//  Clock gen                         
//================================================================
always #20 clk_1x = ~clk_1x;
always #4  clk_5x = ~clk_5x;


//================================================================
//  Initial block
//================================================================
initial begin
	$dumpfile("hdmi.vcd");
	$dumpvars();
end

initial begin
// initial setting
	force clk_1x 	= 0;
	force clk_5x	= 0;
	rgb_red   		= 8'b0; 
	de				= 0;
	hsync			= 0;
	vsync			= 0;
	
	reset_task;
	
	#10;
	hsync			= 0;
	vsync			= 0;
	de 				= 1;
	
	rgb_red 	= 8'b1111_1000;
	
	repeat(100) @(negedge clk_1x);
	$finish;
	
end

//================================================================
//  reset_task       
//================================================================
task reset_task; begin
	#(0.5); sys_rst_n = 1'b0;
	#(2.0);
	#(1.0); sys_rst_n = 1'b1;
	#(3.0)
	release clk_1x; 
	release clk_5x;
end endtask

endmodule