//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : I2C_Master.v
//   Module Name : I2C_Master
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module I2C_Master( 
			   // input
			   clk,
			   rst_n,
			   
			   i_i2c_en,
			   i_device_addr,
			   i_data_addr,
			   i_write_data,
				
			   // output
			   o_done_flag,
			   o_scl,
			   o_sda_mode,
			   
			   // inout
			   io_sda
			  );

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
//input 
input clk;                       // 50MHz sys_clk
input rst_n;                     
								 
input i_i2c_en;                  // i2c_master enable
input [6:0] i_device_addr;	     // device address
input [7:0] i_data_addr;         // data address 
input [7:0] i_write_data;        // data
								 
// output                        
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
parameter C_DIV_SELECT3 = (C_DIV_SELECT >> 1) + 1;				// 1/2 of sel + 1 = 251

localparam IDLE           = 4'd0 ;              // IDLE 
localparam LOAD_ADDR      = 4'd1 ;				// load device address
localparam LOAD_DATA_ADDR = 4'd2 ;				// load data start address
localparam LOAD_DATA      = 4'd3 ;				// load data
localparam START_BIT      = 4'd4 ;				// start passing first bit
localparam BYTE           = 4'd5 ;				// 1 BYTE processing
localparam ACK            = 4'd6 ;				// ACK
localparam PARITY         = 4'd7 ;				// ACK state check 
localparam STOP_BIT       = 4'd8 ;				// STOP passing 
localparam DONE           = 4'd9 ;				// DONE state

//================================================================
//  Wires & Registers
//================================================================
reg [9:0] r_scl_cnt;           // scl_generator counter
reg r_scl_en;                  // scl_enable
reg r_sda_reg;	               // sda register
reg [7:0] r_load_data;         // source data, device addr, data addr
reg [3:0] r_bit_cnt;           // sending data bit number counter
reg r_ack_flag;                // ack flag

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
			if(i_i2c_en == 1)
				next_state = LOAD_ADDR;
			else
				next_state = IDLE;
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
			if(w_scl_high_mid)
				next_state = BYTE;
			else
				next_state = START_BIT;
		end
		
		BYTE: begin
			if(w_scl_low_mid) begin
				if(r_bit_cnt == 4'd8)
					next_state = ACK;
			end
			else
				next_state = BYTE;
		end
		
		ACK: begin
			if(w_scl_high_mid) 
				next_state = PARITY;
			else
				next_state = ACK;
		end
		
		PARITY:	begin
			if(r_ack_flag == 1'b0) begin
				if(w_scl_neg == 1'b1)
					next_state = jump_next_state;
				else
					next_state = PARITY;
			end
		end
		
		STOP_BIT: begin
			if(w_scl_high_mid)
				next_state = DONE;
			else
				next_state = STOP_BIT;
		end
		
		DONE: begin
			if(o_done_flag == 1'b0)
				next_state = IDLE;
			else
				next_state = DONE;
		end
		
		default: next_state = IDLE;
	endcase
end

// datapath
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		o_sda_mode          <= 1'b1;
		r_sda_reg           <= 1'b1;
		r_bit_cnt           <= 4'd0;
		o_done_flag         <= 1'b0;
		r_ack_flag          <= 1'b0;
	end 
	else if(i_i2c_en) begin
		case(curr_state)
			IDLE: begin // In IDLE state, SDA and SCL are actived high
				o_sda_mode    <= 1'b1; // make sda become output 
				r_sda_reg     <= 1'b1; // pull sda high
				r_scl_en      <= 1'b0; // shut scl down
				r_bit_cnt     <= 4'd0; // clear bit counter
				o_done_flag   <= 1'b0;  
			end
			
			LOAD_ADDR: begin
				r_load_data <= {i_device_addr, 1'b0}; // 0 represent that master  
												      // writes data to slave
													  // 1 represent that master
													  // reads data from slave
			end
			
			LOAD_DATA_ADDR: begin
				r_load_data <= i_data_addr;
			end
			
			LOAD_DATA: begin
				r_load_data <= i_write_data;
			end
			
			START_BIT: begin
				r_scl_en   <= 1'b1;                     // open scl 
				o_sda_mode <= 1'b1;						// sda is "output" 
				if(w_scl_high_mid) 
					r_sda_reg <= 1'b0;
			end
			
			BYTE: begin
				r_scl_en   <= 1'b1;						// open scl 
				o_sda_mode <= 1'b1;                     // sda is "output"
				if(w_scl_low_mid) begin
					if(r_bit_cnt == 4'd8)
						r_bit_cnt <= 4'd0;
					else begin
						r_sda_reg <= r_load_data[7 - r_bit_cnt]; // MSB have priority
						r_bit_cnt <= r_bit_cnt + 1'b1;       
					end	
				end
			end
			
			ACK: begin
				r_scl_en   <= 1'b1;						// open scl 
				o_sda_mode <= 1'b0;                     // sda is "input"
				if(w_scl_high_mid)
					r_ack_flag <= io_sda;				// when sda is "input"
														// Slave need to return signal
														// to Master through io_sda
			end
			
			PARITY: begin
				r_scl_en <= 1'b1;						// open scl
				if(r_ack_flag == 1'b0) begin
					if(w_scl_neg == 1'b1) begin			// when scl_neg is actived,
														// then ready passing next BYTE
						o_sda_mode <= 1'b1;				
						r_sda_reg  <= 1'b0;
					end
				end
			end
			
			STOP_BIT: begin
				r_scl_en   <= 1'b1;
				o_sda_mode <= 1'b1;
				if(w_scl_high_mid)
					r_sda_reg <= 1'b1;
			end
			
			DONE: begin
				r_scl_en      <= 1'b0;
				o_sda_mode    <= 1'b1;
				r_sda_reg     <= 1'b1;
				o_done_flag   <= 1'b1;
				r_ack_flag    <= 1'b0;
			end
		endcase
	end
	else begin
		o_sda_mode          <= 1'b1;
		r_sda_reg           <= 1'b1;
		r_bit_cnt           <= 4'd0;
		o_done_flag         <= 1'b0;
		r_ack_flag          <= 1'b0;
	end
end

endmodule