//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : I2C_Master.v
//   Module Name : I2C_Master
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module I2C_Master( // input
			   clk,
			   rst_n,
			   
			   i_i2c_en,
			   i_device_addr,
			   i_data_addr,
			   i_write_data,
				
			   // output
			   o_done_flag,
			   o_scl,
			   
			   // inout
			   io_sda
			  );

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
//input 
input clk;
input rst_n;

input i_i2c_en;
input [6:0] i_device_addr;
input [7:0] i_data_addr;
input [7:0] i_write_data;

// output
output reg o_done_flag;
output o_scl;

// inout
inout wire io_sda;

//================================================================
//  integer / genvar / parameters
//================================================================
parameter C_DIV_SELECT  = 10'd500;								
parameter C_DIV_SELECT0 = (C_DIV_SELECT >> 2) - 1;              // 1/4 of sel = 124
parameter C_DIV_SELECT1 = (C_DIV_SELECT >> 1) - 1;				// 1/2 of sel = 249
parameter C_DIV_SELECT2 = (C_DIV_SELECT0 + C_DIV_SELECT1) + 1;  // 3/4 of sel = 374
parameter C_DIV_SELECT3 = (C_DIV_SELECT >> 1) + 1;				// 1/2 of sel + 1 = 251

localparam IDLE           = 4'd0 ;
localparam LOAD_ADDR      = 4'd1 ;
localparam LOAD_DATA_ADDR = 4'd2 ;
localparam LOAD_DATA      = 4'd3 ;
localparam START_BIT      = 4'd4 ;
localparam BYTE           = 4'd5 ;
localparam ACK_or_NACK    = 4'd6 ;
localparam PARITY         = 4'd7 ;
localparam STOP_BIT       = 4'd8 ;
localparam DONE           = 4'd9 ;

//================================================================
//  Wires & Registers
//================================================================
reg [9:0] scl_cnt;          // scl_generator counter
reg scl_en;                 // scl_enable
reg sda_mode;               // sda mode, 1'b1 is output, 1'b0 is input
reg sda_reg;	            // sda register
reg [7:0] load_data;        // source data, device addr, data addr
reg [3:0] bit_cnt;          // sending data bit number counter
reg ack_flag;               // ack flag

reg [3:0] curr_state;       // state transfer without bit
reg [3:0] next_state;       // state transfer without bit

reg [3:0] jump_curr_state;  // state transfer with bit
reg [3:0] jump_next_state;  // state transfer with bit


wire scl_low_mid;           // 3/4 of scl => 3/4 of DIV = DIV2
wire scl_high_mid;			// 1/4 of scl => 1/4 of DIV = DIV0
wire scl_neg;               // 1/2 of scl => 1/2 of DIV + 1 sys_cycle = DIV3

//================================================================
//  SDA output
//================================================================
assign io_sda = (sda_mode == 1'b1) ? sda_reg:1'b0;  // if mode is 1'b1, then output the data (sda_reg)
												    // Otherwise, do nothing ( 1'b0 )

//================================================================
//  clk divide
//================================================================						   
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		scl_cnt <= 10'd0;
	end
	else if(scl_en) begin
		if(scl_cnt == C_DIV_SELECT - 1'b1)
			scl_cnt <= 10'd0;
		else
			scl_cnt <= scl_cnt + 1'b1;
	end
	else
		scl_cnt <= 10'd0;
end

assign o_scl        = (scl_cnt <= C_DIV_SELECT1) ? 1'b1:1'b0;  // sel_1 = 254, div = 500
													           // mean |‾‾‾|___ every 254 
													           // sys cycle do transistion once  
assign scl_low_mid  = (scl_cnt == C_DIV_SELECT2) ? 1'b1:1'b0;  // 3/4 of sel 
assign scl_high_mid = (scl_cnt == C_DIV_SELECT0) ? 1'b1:1'b0;  // 1/4 of sel
assign scl_neg      = (scl_cnt == C_DIV_SELECT3) ? 1'b1:1'b0;  // 1/2 of sel + 1 sys cycle
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
			next_state = LOAD_ADDR;
			jump_next_state = IDLE;
		end
		
		LOAD_ADDR: begin
			next_state = START_BIT;
			jump_next_state = LOAD_DATA_ADDR;
		end
		
		LOAD_DATA_ADDR: begin
			next_state = BYTE;
			jump_next_state = LOAD_DATA;
		end
		
		LOAD_DATA: begin
			next_state = BYTE;
			jump_next_state = STOP_BIT;
		end
		
		START_BIT: begin
			if(scl_high_mid)
				next_state = BYTE;
			else
				next_state = START_BIT;
		end
		
		BYTE: begin
			if(scl_low_mid) begin
				if(bit_cnt == 4'd8)
					next_state = ACK_or_NACK;
			end
			else
				next_state = BYTE;
		end
		
		ACK_or_NACK: begin
			if(scl_high_mid) 
				next_state = PARITY;
			else
				next_state = ACK_or_NACK;
		end
		
		PARITY:	begin
			if(ack_flag == 1'b0) begin
				if(scl_neg == 1'b1)
					next_state = jump_next_state;
				else
					next_state = PARITY;
			end
		end
		
		STOP_BIT: begin
			if(scl_high_mid)
				next_state = DONE;
			else
				next_state = STOP_BIT;
		end
		
		DONE: 			begin
			next_state = IDLE;
		end
		
		default: next_state = IDLE;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		sda_mode    <= 1'b1;
		sda_reg     <= 1'b1;
		bit_cnt     <= 4'd0;
		o_done_flag <= 1'b0;
		ack_flag    <= 1'b0;
	end
	else if(i_i2c_en) begin
		case(curr_state)
			IDLE: begin // In IDLE state, SDA and SCL are actived high
				sda_mode    <= 1'b1; // make sda become output 
				sda_reg     <= 1'b1; // pull sda high
				scl_en      <= 1'b0; // shut scl down
				bit_cnt     <= 4'd0; // clear bit counter
				o_done_flag <= 1'b0; // 
			end
			
			LOAD_ADDR: begin
				load_data <= {i_device_addr, 1'b0}; // 0 represent that master  
												    // writes data from slave
			end
			
			LOAD_DATA_ADDR: begin
				load_data <= i_data_addr;
			end
			
			LOAD_DATA: begin
				load_data <= i_write_data;
			end
			
			START_BIT: begin
				scl_en   <= 1'b1;
				sda_mode <= 1'b1;
				if(scl_high_mid) 
					sda_reg <= 1'b0;
			end
			
			BYTE: begin
				scl_en   <= 1'b1;
				sda_mode <= 1'b1;
				if(scl_low_mid) begin
					if(bit_cnt == 4'd8)
						bit_cnt <= 4'd0;
					else begin
						sda_reg <= load_data[7-bit_cnt]; // MSB have priority
						bit_cnt <= bit_cnt + 1'b1;       
					end	
				end
			end
			
			ACK_or_NACK: begin
				scl_en   <= 1'b1;
				sda_mode <= 1'b0;
				if(scl_high_mid)
					ack_flag <= io_sda;
			end
			
			PARITY: begin
				scl_en <= 1'b1;
				if(ack_flag == 1'b0) begin
					if(scl_neg == 1'b1) begin
						sda_mode <= 1'b1;
						sda_reg  <= 1'b0;
					end
				end
			end
			
			STOP_BIT: begin
				scl_en   <= 1'b1;
				sda_mode <= 1'b1;
				if(scl_high_mid)
					sda_reg <= 1'b1;
			end
			
			DONE: begin
				scl_en      <= 1'b0;
				sda_mode    <= 1'b1;
				sda_reg     <= 1'b1;
				o_done_flag <= 1'b1;
				ack_flag    <= 1'b0;
			end
		endcase
	end
	else begin
		sda_mode    <= 1'b1;
		sda_reg     <= 1'b1;
		bit_cnt     <= 4'd0;
		o_done_flag <= 1'b0;
		ack_flag    <= 1'b0;
	end
end

endmodule