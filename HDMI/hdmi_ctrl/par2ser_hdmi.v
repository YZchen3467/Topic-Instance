//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : par2ser.v
//   Module Name : par2ser
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`include "par_ddio_out.v"

module par2ser( // input
					clk_5x,
					i_par_data,
				
				// output				
					o_ser_data_p,
					o_ser_data_n
					);
	
//================================================================
//  INPUT AND OUTPUT DECLARATION                         	
//================================================================
// input 
input 		clk_5x;
input [9:0] i_par_data;

// output
output		o_ser_data_p;
output		o_ser_data_n;


//================================================================
//  Wires & Registers
//================================================================
wire [4:0] w_data_rise = {i_par_data[8], i_par_data[6], i_par_data[4], i_par_data[2], i_par_data[0]};
wire [4:0] w_data_fall = {i_par_data[9], i_par_data[7], i_par_data[5], i_par_data[3], i_par_data[1]};

reg  [4:0] r_data_rise = 0;
reg  [4:0] r_data_fall = 0;
reg  [2:0] r_cnt       = 0;


//================================================================
//  count 5 & passing data
//================================================================
always @(posedge clk_5x ) begin
	r_cnt 		<= r_cnt[2] ? 3'd0 : r_cnt + 3'd1;					// counter 5
	r_data_rise <= r_cnt[2] ? w_data_rise : r_data_rise[4:1];
	r_data_fall <= r_cnt[2] ? w_data_fall : r_data_fall[4:1];
end

DDIO_OUT insit_p(
		.datain_h		(r_data_rise[0]				),
		.datain_l		(r_data_fall[0]				),
		.oe				(1'b1						),
		.clk			(clk_5x						),
		.dataout		(o_ser_data_p				)
			);

DDIO_OUT insit_n(
		.datain_h		(~r_data_rise[0]			),
		.datain_l		(~r_data_fall[0]			),
		.oe				(1'b1						),
		.clk			(~clk_5x					),
		.dataout		(o_ser_data_n				)
			);



endmodule