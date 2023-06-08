<<<<<<< HEAD
<<<<<<< HEAD
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : uart_txd.v
//   Module Name : uart_txd
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module uart_txd( // input
				clk,
				rst_n,
				i_tx_start,
				i_baudrate_tx_clk,
				i_data,
				
				// output
				o_rs232_txd,
				o_baudrate_tx_clk_en,
				o_tx_done
				);
				
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================		
input  clk;					        // sys_clk
input  rst_n;					    // sys_rst_n
input  i_tx_start;				    // tx signal start enable
input  i_baudrate_tx_clk;		    // tx baud clk
input  [7:0] i_data;			    // transmission data

output reg o_rs232_txd;				// transfer interface
output reg o_baudrate_tx_clk_en;	// tx baud clk enable
output reg o_tx_done;				// data transmission done signal

//================================================================
//  Wires & Registers
//================================================================
reg transmiting; 					// tell the state machine, the data is transmiting
									// do not do anyting in transmiting state.
 
reg tx_start_delay; 				// the i_tx_start bit need to delay to baud clk falling
									// make sure data transfer keep in enable range
 
reg [3:0] curr_state;
reg [3:0] next_state;

//================================================================
//  integer / genvar / parameters
//================================================================
parameter START = 4'd0;
parameter BIT0  = 4'd1;
parameter BIT1  = 4'd2;
parameter BIT2  = 4'd3;
parameter BIT3  = 4'd4;
parameter BIT4  = 4'd5;
parameter BIT5  = 4'd6;
parameter BIT6  = 4'd7;
parameter BIT7  = 4'd8;
parameter STOP  = 4'd9;
parameter IDLE  = 4'd10;

//================================================================
//  transmiting status checking
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		transmiting <= 1'b0;
	else if(o_tx_done)
		transmiting <= 1'b0;
	else if(i_tx_start)
		transmiting <= 1'b1;
end

//================================================================
//  start delay bit off signals
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		tx_start_delay <= 1'b0;
	end
	else if(i_tx_start)begin
		tx_start_delay <= i_tx_start;
	end
	else if(i_baudrate_tx_clk)
		tx_start_delay <= 1'b0;
end

//================================================================
//  FSM
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		curr_state <= IDLE;
	else
		curr_state <= next_state;
end

always @(*) begin
	next_state = IDLE;
	case(curr_state)
		START: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT0;
			else
				next_state = START;
		end
		BIT0: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT1;
			else
				next_state = BIT0;
		end
		BIT1: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT2;
			else
				next_state = BIT1;
		end
		BIT2: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT3;
			else
				next_state = BIT2;
		end
		BIT3: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT4;
			else
				next_state = BIT3;
		end
		BIT4: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT5;
			else
				next_state = BIT4;
		end
		BIT5: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT6;
			else
				next_state = BIT5;
		end
		BIT6: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT7;
			else
				next_state = BIT6;
		end
		BIT7: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = STOP;
			else
				next_state = BIT7;
		end
		STOP: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = IDLE;
			else
				next_state = STOP;
		end
		IDLE: begin
			if(tx_start_delay && transmiting && i_baudrate_tx_clk)
				next_state = START;
			else
				next_state = IDLE;
		end
		default: next_state = IDLE;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		o_rs232_txd          <= 1'b1;
		o_tx_done            <= 1'b0;
		o_baudrate_tx_clk_en <= 1'b0;
	end
	
	else if(transmiting) begin
		o_baudrate_tx_clk_en <= 1'b1; // when i_tx_start enable, then enable the transmiting
		if(i_baudrate_tx_clk) begin
			case(curr_state)
			// becasue curr_state and state will delay 1 cycle
			// make the o_rs232_txd output early 1 cycle  
				IDLE: begin
					if(tx_start_delay) begin
						o_rs232_txd  <= 1'b0;
						o_tx_done    <= 1'b0;
					end
					else begin
						o_rs232_txd  <= 1'b1;
						o_tx_done    <= 1'b0;
					end
				end     
				START: begin
					o_rs232_txd  <= i_data[7];  // uart start bit is 0
					o_tx_done    <= 1'b0;
				end              
				BIT0: begin      
					o_rs232_txd  <= i_data[6];
					o_tx_done    <= 1'b0;
				end              
				BIT1: begin      
					o_rs232_txd  <= i_data[5];
					o_tx_done    <= 1'b0;
				end              
				BIT2: begin      
					o_rs232_txd  <= i_data[4];
					o_tx_done    <= 1'b0;
				end              
				BIT3: begin      
					o_rs232_txd  <= i_data[3];
					o_tx_done    <= 1'b0;
				end              
				BIT4: begin      
					o_rs232_txd  <= i_data[2];
					o_tx_done    <= 1'b0;
				end              
				BIT5: begin      
					o_rs232_txd  <= i_data[1];
					o_tx_done    <= 1'b0;
				end              
				BIT6: begin      
					o_rs232_txd  <= i_data[0];
					o_tx_done    <= 1'b0;
				end              
				BIT7: begin      
					o_rs232_txd  <= 1'b1;
					o_tx_done    <= 1'b0;
				end
				// STOP state have done, then pull the done signals,
				// therefore, do not make early 1 cycle in this state
				STOP: begin      
					o_rs232_txd  <= 1'b1;  // uart stop bit is 1 
					o_tx_done    <= 1'b1;
				end
			endcase
		end
	end
	
	else begin
		o_rs232_txd          <= 1'b1;
		o_tx_done            <= 1'b0;
		o_baudrate_tx_clk_en <= 1'b0; // when data have been transmitted, disable the baud clk enable
	end
end

endmodule
=======
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : uart_txd.v
//   Module Name : uart_txd
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module uart_txd( // input
				clk,
				rst_n,
				i_tx_start,
				i_baudrate_tx_clk,
				i_data,
				
				// output
				o_rs232_txd,
				o_baudrate_tx_clk_en,
				o_tx_done
				);
				
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================		
input  clk;					        // sys_clk
input  rst_n;					    // sys_rst_n
input  i_tx_start;				    // tx signal start enable
input  i_baudrate_tx_clk;		    // tx baud clk
input  [7:0] i_data;			    // transmission data

output reg o_rs232_txd;				// transfer interface
output reg o_baudrate_tx_clk_en;	// tx baud clk enable
output reg o_tx_done;				// data transmission done signal

//================================================================
//  Wires & Registers
//================================================================
reg transmiting; 					// tell the state machine, the data is transmiting
									// do not do anyting in transmiting state.
 
reg tx_start_delay; 				// the i_tx_start bit need to delay to baud clk falling
									// make sure data transfer keep in enable range
 
reg [3:0] curr_state;
reg [3:0] next_state;

//================================================================
//  integer / genvar / parameters
//================================================================
parameter START = 4'd0;
parameter BIT0  = 4'd1;
parameter BIT1  = 4'd2;
parameter BIT2  = 4'd3;
parameter BIT3  = 4'd4;
parameter BIT4  = 4'd5;
parameter BIT5  = 4'd6;
parameter BIT6  = 4'd7;
parameter BIT7  = 4'd8;
parameter STOP  = 4'd9;
parameter IDLE  = 4'd10;

//================================================================
//  transmiting status checking
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		transmiting <= 1'b0;
	else if(o_tx_done)
		transmiting <= 1'b0;
	else if(i_tx_start)
		transmiting <= 1'b1;
end

//================================================================
//  start delay bit off signals
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		tx_start_delay <= 1'b0;
	end
	else if(i_tx_start)begin
		tx_start_delay <= i_tx_start;
	end
	else if(i_baudrate_tx_clk)
		tx_start_delay <= 1'b0;
end

//================================================================
//  FSM
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		curr_state <= IDLE;
	else
		curr_state <= next_state;
end

always @(*) begin
	next_state = IDLE;
	case(curr_state)
		START: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT0;
			else
				next_state = START;
		end
		BIT0: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT1;
			else
				next_state = BIT0;
		end
		BIT1: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT2;
			else
				next_state = BIT1;
		end
		BIT2: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT3;
			else
				next_state = BIT2;
		end
		BIT3: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT4;
			else
				next_state = BIT3;
		end
		BIT4: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT5;
			else
				next_state = BIT4;
		end
		BIT5: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT6;
			else
				next_state = BIT5;
		end
		BIT6: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT7;
			else
				next_state = BIT6;
		end
		BIT7: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = STOP;
			else
				next_state = BIT7;
		end
		STOP: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = IDLE;
			else
				next_state = STOP;
		end
		IDLE: begin
			if(tx_start_delay && transmiting && i_baudrate_tx_clk)
				next_state = START;
			else
				next_state = IDLE;
		end
		default: next_state = IDLE;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		o_rs232_txd          <= 1'b1;
		o_tx_done            <= 1'b0;
		o_baudrate_tx_clk_en <= 1'b0;
	end
	
	else if(transmiting) begin
		o_baudrate_tx_clk_en <= 1'b1; // when i_tx_start enable, then enable the transmiting
		if(i_baudrate_tx_clk) begin
			case(curr_state)
				IDLE: begin
					if(tx_start_delay) begin
						o_rs232_txd  <= 1'b0;
						o_tx_done    <= 1'b0;
					end
					else begin
						o_rs232_txd  <= 1'b1;
						o_tx_done    <= 1'b0;
					end
				end     
				START: begin
					o_rs232_txd  <= i_data[7];  // uart start bit is 0
					o_tx_done    <= 1'b0;
				end              
				BIT0: begin      
					o_rs232_txd  <= i_data[6];
					o_tx_done    <= 1'b0;
				end              
				BIT1: begin      
					o_rs232_txd  <= i_data[5];
					o_tx_done    <= 1'b0;
				end              
				BIT2: begin      
					o_rs232_txd  <= i_data[4];
					o_tx_done    <= 1'b0;
				end              
				BIT3: begin      
					o_rs232_txd  <= i_data[3];
					o_tx_done    <= 1'b0;
				end              
				BIT4: begin      
					o_rs232_txd  <= i_data[2];
					o_tx_done    <= 1'b0;
				end              
				BIT5: begin      
					o_rs232_txd  <= i_data[1];
					o_tx_done    <= 1'b0;
				end              
				BIT6: begin      
					o_rs232_txd  <= i_data[0];
					o_tx_done    <= 1'b0;
				end              
				BIT7: begin      
					o_rs232_txd  <= 1'b1;
					o_tx_done    <= 1'b0;
				end              
				STOP: begin      
					o_rs232_txd  <= 1'b1;  // uart stop bit is 1 
					o_tx_done    <= 1'b1;
				end
			endcase
		end
	end
	
	else begin
		o_rs232_txd          <= 1'b1;
		o_tx_done            <= 1'b0;
		o_baudrate_tx_clk_en <= 1'b0; // when data have been transmitted, disable the baud clk enable
	end
end

endmodule
>>>>>>> 17b668c496893641e9891cc2cdfa404909e40e7e
=======
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : uart_txd.v
//   Module Name : uart_txd
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module uart_txd( // input
				clk,
				rst_n,
				i_tx_start,
				i_baudrate_tx_clk,
				i_data,
				
				// output
				o_rs232_txd,
				o_baudrate_tx_clk_en,
				o_tx_done
				);
				
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================		
input  clk;					        // sys_clk
input  rst_n;					    // sys_rst_n
input  i_tx_start;				    // tx signal start enable
input  i_baudrate_tx_clk;		    // tx baud clk
input  [7:0] i_data;			    // transmission data

output reg o_rs232_txd;				// transfer interface
output reg o_baudrate_tx_clk_en;	// tx baud clk enable
output reg o_tx_done;				// data transmission done signal

//================================================================
//  Wires & Registers
//================================================================
reg transmiting; 					// tell the state machine, the data is transmiting
									// do not do anyting in transmiting state.
 
reg tx_start_delay; 				// the i_tx_start bit need to delay to baud clk falling
									// make sure data transfer keep in enable range
 
reg [3:0] curr_state;
reg [3:0] next_state;

//================================================================
//  integer / genvar / parameters
//================================================================
parameter START = 4'd0;
parameter BIT0  = 4'd1;
parameter BIT1  = 4'd2;
parameter BIT2  = 4'd3;
parameter BIT3  = 4'd4;
parameter BIT4  = 4'd5;
parameter BIT5  = 4'd6;
parameter BIT6  = 4'd7;
parameter BIT7  = 4'd8;
parameter STOP  = 4'd9;
parameter IDLE  = 4'd10;

//================================================================
//  transmiting status checking
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		transmiting <= 1'b0;
	else if(o_tx_done)
		transmiting <= 1'b0;
	else if(i_tx_start)
		transmiting <= 1'b1;
end

//================================================================
//  start delay bit off signals
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		tx_start_delay <= 1'b0;
	end
	else if(i_tx_start)begin
		tx_start_delay <= i_tx_start;
	end
	else if(i_baudrate_tx_clk)
		tx_start_delay <= 1'b0;
end

//================================================================
//  FSM
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		curr_state <= IDLE;
	else
		curr_state <= next_state;
end

always @(*) begin
	next_state = IDLE;
	case(curr_state)
		START: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT0;
			else
				next_state = START;
		end
		BIT0: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT1;
			else
				next_state = BIT0;
		end
		BIT1: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT2;
			else
				next_state = BIT1;
		end
		BIT2: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT3;
			else
				next_state = BIT2;
		end
		BIT3: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT4;
			else
				next_state = BIT3;
		end
		BIT4: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT5;
			else
				next_state = BIT4;
		end
		BIT5: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT6;
			else
				next_state = BIT5;
		end
		BIT6: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = BIT7;
			else
				next_state = BIT6;
		end
		BIT7: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = STOP;
			else
				next_state = BIT7;
		end
		STOP: begin
			if(transmiting && i_baudrate_tx_clk)
				next_state = IDLE;
			else
				next_state = STOP;
		end
		IDLE: begin
			if(tx_start_delay && transmiting && i_baudrate_tx_clk)
				next_state = START;
			else
				next_state = IDLE;
		end
		default: next_state = IDLE;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		o_rs232_txd          <= 1'b1;
		o_tx_done            <= 1'b0;
		o_baudrate_tx_clk_en <= 1'b0;
	end
	
	else if(transmiting) begin
		o_baudrate_tx_clk_en <= 1'b1; // when i_tx_start enable, then enable the transmiting
		if(i_baudrate_tx_clk) begin
			case(curr_state)
				IDLE: begin
					if(tx_start_delay) begin
						o_rs232_txd  <= 1'b0;
						o_tx_done    <= 1'b0;
					end
					else begin
						o_rs232_txd  <= 1'b1;
						o_tx_done    <= 1'b0;
					end
				end     
				START: begin
					o_rs232_txd  <= i_data[7];  // uart start bit is 0
					o_tx_done    <= 1'b0;
				end              
				BIT0: begin      
					o_rs232_txd  <= i_data[6];
					o_tx_done    <= 1'b0;
				end              
				BIT1: begin      
					o_rs232_txd  <= i_data[5];
					o_tx_done    <= 1'b0;
				end              
				BIT2: begin      
					o_rs232_txd  <= i_data[4];
					o_tx_done    <= 1'b0;
				end              
				BIT3: begin      
					o_rs232_txd  <= i_data[3];
					o_tx_done    <= 1'b0;
				end              
				BIT4: begin      
					o_rs232_txd  <= i_data[2];
					o_tx_done    <= 1'b0;
				end              
				BIT5: begin      
					o_rs232_txd  <= i_data[1];
					o_tx_done    <= 1'b0;
				end              
				BIT6: begin      
					o_rs232_txd  <= i_data[0];
					o_tx_done    <= 1'b0;
				end              
				BIT7: begin      
					o_rs232_txd  <= 1'b1;
					o_tx_done    <= 1'b0;
				end              
				STOP: begin      
					o_rs232_txd  <= 1'b1;  // uart stop bit is 1 
					o_tx_done    <= 1'b1;
				end
			endcase
		end
	end
	
	else begin
		o_rs232_txd          <= 1'b1;
		o_tx_done            <= 1'b0;
		o_baudrate_tx_clk_en <= 1'b0; // when data have been transmitted, disable the baud clk enable
	end
end

endmodule
>>>>>>> 39059d7608a97f01c32b431de6bb75b2ca74f4cd
