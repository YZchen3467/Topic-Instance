//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : hdmi_ctrl.v
//   Module Name : hdmi_ctrl
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`include "TMDS_encoder_hdmi.v"
`include "par2ser_hdmi.v"

module hdmi_ctrl(// input
				clk_1x,
				clk_5x,
				sys_rst_n,
				rgb_red,
				// rgb_green,
				// rgb_blue,
				hsync,
				vsync,
				de,
				
				
				// output
				hdmi_clk_p,
				hdmi_clk_n,
				hdmi_r_p,
				hdmi_r_n,
				// hdmi_g_p,
				// hdmi_g_n,
				// hdmi_b_p,
				// hdmi_b_n
);

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
// input
input 		clk_1x;
input 		clk_5x;
input 		sys_rst_n;
input [7:0] rgb_red;
// input [7:0] rgb_green;
// input [7:0] rgb_blue;
input		hsync;
input		vsync;
input		de;

// output
output		hdmi_clk_p;
output      hdmi_clk_n;
output      hdmi_r_p;
output      hdmi_r_n;


//================================================================
//  Wires & Registers
//================================================================
wire [9:0] red;
// wire [9:0] green;
// wire [9:0] blue; 


//================================================================
//  TMDS encoder
//================================================================
TMDS_encoder encoder_inst_r(
			.clk		(clk_1x					),
			.rst_n		(sys_rst_n				),
			.i_din		(rgb_red				),
			.i_c0		(hsync					),
			.i_c1		(vsync					),
			.i_de		(de						),
			.o_dout		(red					)
);

/*TMDS_encoder encoder_inst_g(
			.clk		(clk_1x					),
			.rst_n		(sys_rst_n				),
			.i_din		(rgb_red				),
			.i_c0		(hsync					),
			.i_c1		(vsync					),
			.i_de		(de						),
			.o_dout		(green					)
				);

TMDS_encoder encoder_inst_b(
			.clk		(clk_1x					),
			.rst_n		(sys_rst_n				),
			.i_din		(rgb_red				),
			.i_c0		(hsync					),
			.i_c1		(vsync					),
			.i_de		(de						),
			.o_dout		(blue					)
				);*/


//================================================================
//  par to ser
//================================================================
par2ser p2s_inst_r(
			.clk_5x			(clk_5x				),
			.i_par_data		(red				),
			.o_ser_data_p	(hdmi_r_p			),
			.o_ser_data_n	(hdmi_r_n			)
);

/* par2ser p2s_inst_g(
			.clk_5x(),
			.i_par_data(),
			.o_ser_data_p(),
			.o_ser_data_n(),
);

par2ser p2s_inst_b(
			.clk_5x(),
			.i_par_data(),
			.o_ser_data_p(),
			.o_ser_data_n(),
); */


endmodule