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
			   o_slave_state,	//*** just for simulation ***//
			   
			   // inout
			   io_sda
);

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input clk;                       // 50MHz sys_clk
input rst_n;                     
								 
input i_i2c_recv_en;             // i2c_master enable
input [6:0] i_device_addr;	     // device address
input [7:0] i_data_addr;         // data address 
								 
// output
output reg [7:0] o_read_data;    // recived data                        
output reg o_done_flag;          // done_flag
output o_scl;                    // i2c clk
output reg o_sda_mode;           // sda mode => 1 output signal / 0 input signal
output reg [1:0] o_slave_state;	 // ack state check, 1 -> ack state, 2 -> readbyte,
								 // 0 -> normal status ||| just for simulation

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
reg r_scl_high_mid;            // eliminate meta stable
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
//  eliminate metastable in BYTE_READING
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		r_scl_high_mid <= 1'b0;
	end
	else if(curr_state == 4'd9) begin
		if(w_scl_high_mid && r_bit_cnt == 4'd7)
			r_scl_high_mid <= 1'b1;
	end
	else
		r_scl_high_mid <= 1'b0;
end

//================================================================
//  SDA 
//================================================================
assign io_sda = (o_sda_mode == 1'b1) ? r_sda_reg:1'bz;  // if mode is 1'b1, then output the data (sda_reg)
												        // Otherwise, do nothing and should be high 
													    // impendence (inout port should be a tristate)

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
		
		BYTE_SEND: begin
			if(w_scl_low_mid) begin
				if(r_bit_cnt == 4'd8)
					next_state = ACK;
			end
			else
				next_state = BYTE_SEND;
		end
		
		ACK: begin
			if(w_scl_high_mid)
				next_state = ACK_PARITY;
			else
				next_state = ACK;
		end
		
		ACK_PARITY: begin
			if(!r_ack_flag) begin
				if(w_scl_neg)
					next_state = jump_next_state;
				else
					next_state = ACK_PARITY;
			end
			else
				next_state = IDLE;
		end
		
		READ_SIGNAL: begin
			if(w_scl_high_mid)
				next_state = LOAD_READ_ADDR;
			else
				next_state = READ_SIGNAL;
		end
		
		LOAD_READ_ADDR: begin
			next_state = BYTE_SEND;
			jump_next_state = BYTE_READ;
		end
		
		BYTE_READ: begin
			if(r_scl_high_mid) begin // delay the scl_high_mid in here to make sure reading state have completed
				if(r_bit_cnt == 4'd7)
					next_state = NACK;
				else
					next_state = BYTE_READ;
			end
		end
		
		NACK: begin
			if(w_scl_low_mid)
				next_state = NACK_PARITY;
			else
				next_state = NACK;
		end
		
		NACK_PARITY: begin
			if(w_scl_low_mid)
				next_state = STOP_BIT;
			else
				next_state = NACK_PARITY;
		end
		
		STOP_BIT: begin
			if(w_scl_high_mid) // this part need to add delay for eliminate meta stable
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
	if(!rst_n) begin
		o_sda_mode      <= 1'b1;		// read mode
		o_done_flag     <= 1'b0;
		o_read_data     <= 8'd0;
		o_slave_state   <= 2'b00;		// for simulation
		r_sda_reg  	    <= 1'b1;
		r_bit_cnt  	    <= 4'd0;
		r_read_data     <= 8'd0;
		r_ack_flag      <= 1'b0;
	end
	
	else if(i_i2c_recv_en) begin
		case(curr_state)
			IDLE: begin
				o_sda_mode      <= 1'b1;		// output mode
				o_done_flag     <= 1'b0;
				r_sda_reg       <= 1'b1; 	    // when ready for sending BYTE
							     			    // sda need to keep high
				r_scl_en        <= 1'b0;
				r_bit_cnt       <= 4'd0;
				r_read_data     <= 8'd0;
			end
			
			LOAD_SEND_ADDR: begin
				r_load_data <= {i_device_addr, 1'b0};	// 0 represet that is sending mode
			end			
				
			LOAD_DATA_ADDR: begin
				r_load_data <= i_data_addr;
			end
			
			START_LOAD_BIT: begin
				r_scl_en   <= 1'b1;			// open the scl
				o_sda_mode <= 1'b1;
				if(w_scl_high_mid)
					r_sda_reg <= 1'b0;
			end
			
			BYTE_SEND: begin 
				r_scl_en   <= 1'b1;
                o_sda_mode <= 1'b1;
				if(w_scl_low_mid) begin
					if(r_bit_cnt == 4'd8)
						r_bit_cnt <= 4'd0;
					else begin
						r_sda_reg <= r_load_data[7 - r_bit_cnt];
						r_bit_cnt <= r_bit_cnt + 1'b1;
					end
				end
			end
			
			ACK: begin
				r_sda_reg  <= 1'b0;
				r_scl_en   <= 1'b1;
				o_sda_mode <= 1'b0;		// input mode, slave input signal to Master until
										// o_sda_mode <= 1'b1 again.
				o_slave_state <= 2'b01;
				if(w_scl_high_mid)
					r_ack_flag    <= io_sda;
			end
			
			ACK_PARITY: begin
				r_scl_en      <= 1'b1;
				// o_slave_state <= 2'b00; 	  // when after ack state, then close the ack_state enable
				if(r_ack_flag == 1'b0) begin  // if ack_parity have be passed
					if(w_scl_neg) begin
						if(next_state == BYTE_READ) begin
							o_sda_mode <= 1'b0;
							r_sda_reg  <= 1'b1;
						end
						else begin	
							o_sda_mode <= 1'b1;
							r_sda_reg  <= 1'b1;  // let sda into stand by stauts
						end
					end
				end	
			end
			
			READ_SIGNAL: begin 
				r_scl_en   <= 1'b1;
				o_sda_mode <= 1'b1;
				if(w_scl_high_mid)  
					r_sda_reg <= 1'b0;
			end 
			
			LOAD_READ_ADDR: begin 
				r_load_data <= {i_device_addr, 1'b1};	// 0 represet that is reading mode
			end
			
			BYTE_READ: begin 
				r_scl_en   <= 1'b1;
				o_sda_mode <= 1'b0;
				o_slave_state <= 2'b10;
				if(w_scl_high_mid) begin
					if(r_bit_cnt == 4'd7) begin
						o_slave_state   <= 2'b00;
						r_bit_cnt       <= 4'd0;
						o_read_data     <= {r_read_data[6:0], io_sda};						
					end
					else begin
						r_read_data     <= {r_read_data[6:0], io_sda};
						r_bit_cnt       <= r_bit_cnt + 1'b1;
					end
				end
			end
			
			NACK: begin 
				r_scl_en   <= 1'b1;
				o_sda_mode <= 1'b1;
				if(w_scl_low_mid)
					r_sda_reg <= 1'b1;
			end
			
			NACK_PARITY: begin 
				r_scl_en   <= 1'b1;
				o_sda_mode <= 1'b1;
				if(w_scl_low_mid)
					r_sda_reg <= 1'b0;
			end
			
			STOP_BIT: begin 
				r_scl_en   <= 1'b1;
				o_sda_mode <= 1'b1;
				if(w_scl_high_mid) begin 
					r_sda_reg <= 1'b1;
				end
			end
			
			DONE: begin 
				o_done_flag <= 1'b1;
				o_sda_mode  <= 1'b1;	// input mode
				r_sda_reg  	<= 1'b1;	// pull high let sda into standby status
				r_scl_en	<= 1'd0;	// close i2c clk
				r_read_data <= 8'd0;	
			end
		endcase
	end
	
	else begin 
		o_sda_mode      <= 1'b1;		// read mode
		o_done_flag     <= 1'b0;
		o_read_data     <= 8'd0;
		o_slave_state   <= 2'b00;		// for simulation
		r_sda_reg  	    <= 1'b1;
		r_bit_cnt  	    <= 4'd0;
		r_read_data     <= 8'd0;
		r_ack_flag      <= 1'b0;
	end
	
end

endmodule