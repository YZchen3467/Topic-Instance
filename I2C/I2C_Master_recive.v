//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : I2C_Master_recive.v
//   Module Name : I2C_Master_recive
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module I2C_Master_recive(
			   // input
			   clk,
			   rst_n,
			   
			   i_i2c_recv_en,
			   i_device_addr,
			   i_data_addr,
				
			   // output
			   o_read_data,
			   o_done_flag,
			   o_scl,
			   o_sda_mode,
			   
			   // inout
			   io_sda
);

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input clk;                       // 50MHz sys_clk
input rst_n;                     
								 
input i_i2c_recv_en;                  // i2c_master enable
input [6:0] i_device_addr;	     // device address
input [7:0] i_data_addr;         // data address 
								 
// output
output reg [7:0] o_read_data;    // recived data                        
output reg o_done_flag;          // done_flag
output o_scl;                    // i2c clk
output reg o_sda_mode;           // sda mode => 1 output signal / 0 input signal

// inout
inout wire io_sda;

//================================================================
//  integer / genvar / parameters
//================================================================
parameter C_DIV_SELECT  = 10'd500;								
parameter C_DIV_SELECT0 = (C_DIV_SELECT >> 2) - 1;              // 1/4 of sel = 124
parameter C_DIV_SELECT1 = (C_DIV_SELECT >> 1) - 1;				// 1/2 of sel = 249
parameter C_DIV_SELECT2 = (C_DIV_SELECT0 + C_DIV_SELECT1) + 1;  // 3/4 of sel = 374
parameter C_DIV_SELECT3 = (C_DIV_SELECT >> 1) + 1;		

//------- send mode -------//
localparam IDLE             = 4'd0 ;			// IDLE
localparam LOAD_SEND_ADDR   = 4'd1 ;			// load device address for writing
localparam LOAD_DATA_ADDR   = 4'd2 ;			// load data start address
localparam START_LOAD_BIT   = 4'd3 ;			// start sending firt bit 
localparam BYTE_SEND        = 4'd4 ;			// 1 BYTE sending
localparam ACK              = 4'd5 ;			// ack
localparam ACK_PARITY       = 4'd6 ;			// ack state check 
//------- read mode -------//
localparam READ_SIGNAL      = 4'd7 ;			// start read operation
localparam LOAD_READ_ADDR	= 4'd8 ;			// load device address for reading
localparam BYTE_READ	    = 4'd9 ;			// 1 BYTE reading
localparam NACK             = 4'd10;			// nack
localparam NACK_PARITY      = 4'd11;		    // nack state check
localparam STOP_BIT         = 4'd12;			// STOP passing
localparam DONE             = 4'd13;			// DONE state

//================================================================
//  Wires & Registers
//================================================================
reg [9:0] r_scl_cnt;           // scl_generator counter
reg r_scl_en;                  // scl_enable
reg r_sda_reg;	               // sda register
reg [7:0] r_load_data;         // source data, device addr, data addr
reg [7:0] r_read_data;
reg [3:0] r_bit_cnt;           // sending data bit number counter
reg r_ack_flag;                // ack flag for master write_data to slave
reg r_nack_flag;               // nack flag for master read_data from slave


reg [3:0] curr_state;          // state transfer without bit
reg [3:0] next_state;          // state transfer without bit

reg [3:0] jump_curr_state;     // state transfer with bit
reg [3:0] jump_next_state;     // state transfer with bit


wire w_scl_low_mid;            // 3/4 of scl => 3/4 of DIV = DIV2
wire w_scl_high_mid;		   // 1/4 of scl => 1/4 of DIV = DIV0
wire w_scl_neg;                // 1/2 of scl => 1/2 of DIV + 1 sys_cycle = DIV3

//================================================================
//  SDA 
//================================================================
assign io_sda = (o_sda_mode == 1'b1) ? r_sda_reg:1'bz;  // if mode is 1'b1, then output the data (sda_reg)
												        // Otherwise, do nothing and should be high 
													    // impendence (inout port should be a tristate)

//================================================================
//  clk divide
//================================================================						   
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		r_scl_cnt <= 10'd0;
	end
	else if(r_scl_en) begin
		if(r_scl_cnt == C_DIV_SELECT - 1'b1)
			r_scl_cnt <= 10'd0;
		else
			r_scl_cnt <= r_scl_cnt + 1'b1;
	end
	else
		r_scl_cnt <= 10'd0;
end

assign o_scl          = (r_scl_cnt <= C_DIV_SELECT1) ? 1'b1:1'b0;  // sel_1 = 254, div = 500
													               // mean |‾‾‾|___ every 254 
													               // sys cycle do transistion once  
assign w_scl_low_mid  = (r_scl_cnt == C_DIV_SELECT2) ? 1'b1:1'b0;  // 3/4 of sel 
assign w_scl_high_mid = (r_scl_cnt == C_DIV_SELECT0) ? 1'b1:1'b0;  // 1/4 of sel
assign w_scl_neg      = (r_scl_cnt == C_DIV_SELECT3) ? 1'b1:1'b0;  // 1/2 of sel + 1 sys cycle
				                                                   // For marking scl negedge location 

//================================================================
//  FSM 
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		curr_state <= IDLE;
		jump_curr_state <= IDLE;
	end
	else begin
		curr_state <= next_state;
		jump_curr_state <= jump_next_state;
	end
end

always @(*) begin
	case(curr_state)
		IDLE: begin
			if(i_i2c_recv_en)
				next_state = LOAD_SEND_ADDR;
			else
				next_state = IDLE;
			jump_next_state = IDLE;
		end
		
		LOAD_SEND_ADDR: begin
			next_state = START_LOAD_BIT;
			jump_next_state = LOAD_DATA_ADDR;
		end
		
		LOAD_DATA_ADDR: begin 
			next_state = BYTE_SEND;
			jump_next_state = READ_SIGNAL;
		end
		
		START_LOAD_BIT: begin
			if(w_scl_high_mid)
				next_state = BYTE_SEND;
			else
				next_state = START_LOAD_BIT;
		end
		
		
	endcase
end

endmodule