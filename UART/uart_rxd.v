<<<<<<< HEAD
<<<<<<< HEAD
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : uart_rxd.v
//   Module Name : uart_rxd
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module uart_rxd( // input
				clk,
				rst_n,
				i_rx_start,
				i_baudrate_rx_clk,
				i_rs232_rxd,
				
				// output
				o_data,
				o_baudrate_rx_clk_en,
				o_rx_done
				);
				
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input  clk;					        // sys_clk
input  rst_n;					    // sys_rst_n
input  i_rx_start;				    // rx signal start enable
input  i_baudrate_rx_clk;		    // rx baud clk
input  i_rs232_rxd;			    	// transfer interface

output reg [7:0] o_data;			// receiving data
output reg o_baudrate_rx_clk_en;	// rx baud clk enable
output reg o_rx_done;

//================================================================
//  Wires & Registers
//================================================================
reg receiving; 						// tell the state machine, uart is receiving
									// do not do anyting in receiving state.

reg [7:0] data_reg; 
 
reg [3:0] curr_state;
reg [3:0] next_state;

reg rs232_delay0;					// dealy 0 and 1 for eliminate metastble
reg rs232_delay1;
reg rs232_delay2;					// delay 2 and 3 for generate rs232_negedge 
reg rs232_delay3;

wire rs232_negedge;

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
//  avoid the Metastable when during the receiving status
//  and generate rs232 location of negedge 
//================================================================
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rs232_delay0 <= 1'b0;
		rs232_delay1 <= 1'b0;
		rs232_delay2 <= 1'b0;
		rs232_delay3 <= 1'b0;
	end
	else begin
		// eliminate Metastable
		rs232_delay0 <= i_rs232_rxd;
		rs232_delay1 <= rs232_delay0;
		
		// generate rs232_negedge
		rs232_delay2 <= rs232_delay1;
		rs232_delay3 <= rs232_delay2;
	end
end

// instead of baud_rx_clk
assign rs232_negedge = (~rs232_delay2) & (rs232_delay3);

//================================================================
//  receiving status checking
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		receiving <= 1'b0;
	else if(o_rx_done)
		receiving <= 1'b0;
	else if(i_rx_start && rs232_negedge)
		receiving <= 1'b1;
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
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT0;
			else
				next_state = START;
		end
		BIT0: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT1;
			else
				next_state = BIT0;
		end
		BIT1: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT2;
			else
				next_state = BIT1;
		end
		BIT2: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT3;
			else
				next_state = BIT2;
		end
		BIT3: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT4;
			else
				next_state = BIT3;
		end
		BIT4: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT5;
			else
				next_state = BIT4;
		end
		BIT5: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT6;
			else
				next_state = BIT5;
		end
		BIT6: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT7;
			else
				next_state = BIT6;
		end
		BIT7: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = STOP;
			else
				next_state = BIT7;
		end
		STOP: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = IDLE;
			else
				next_state = STOP;
		end
		IDLE: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = START;
			else
				next_state = IDLE;
		end
		default: next_state = IDLE;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_reg			 <= 8'b0;
		o_data				 <= 8'b0;		
		o_rx_done			 <= 1'b0;
		o_baudrate_rx_clk_en <= 1'b0;
	end
	
	else if(receiving) begin
		o_baudrate_rx_clk_en <= 1'b1;
		if(i_baudrate_rx_clk) begin
			case(curr_state)
				IDLE: begin
					data_reg 		<= 8'b0;
					o_rx_done   	<= 1'b0;
				end     
				START: begin
					data_reg[7] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT0: begin      
					data_reg[6] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT1: begin      
					data_reg[5] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT2: begin      
					data_reg[4] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT3: begin      
					data_reg[3] 	 <= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT4: begin      
					data_reg[2] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT5: begin      
					data_reg[1] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT6: begin      
					data_reg[0] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT7: begin      
					o_rx_done   	<= 1'b0;
				end
				// STOP state have done, then pull the done signals,
				// therefore, do not make early 1 cycle in this state
				STOP: begin
					o_data			<= data_reg;
					data_reg	 	<= 8'd0;  // uart stop bit is 1 
					o_rx_done   	<= 1'b1;
				end
			endcase
		end
	end
	
	else begin
		data_reg             <= 8'd0;
		o_rx_done 			 <= 1'b0;
		o_baudrate_rx_clk_en <= 1'b0;
	end
	
end

=======
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : uart_rxd.v
//   Module Name : uart_rxd
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module uart_rxd( // input
				clk,
				rst_n,
				i_rx_start,
				i_baudrate_rx_clk,
				i_rs232_rxd,
				
				// output
				o_data,
				o_baudrate_rx_clk_en,
				o_rx_done
				);
				
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input  clk;					        // sys_clk
input  rst_n;					    // sys_rst_n
input  i_rx_start;				    // rx signal start enable
input  i_baudrate_rx_clk;		    // rx baud clk
input  i_rs232_rxd;			    	// transfer interface

output reg [7:0] o_data;			// receiving data
output reg o_baudrate_rx_clk_en;	// rx baud clk enable
output reg o_rx_done;

//================================================================
//  Wires & Registers
//================================================================
reg receiving; 						// tell the state machine, uart is receiving
									// do not do anyting in receiving state.

reg [7:0] data_reg; 
 
reg [3:0] curr_state;
reg [3:0] next_state;

reg rs232_delay0;					// dealy 0 and 1 for eliminate metastble
reg rs232_delay1;
reg rs232_delay2;					// delay 2 and 3 for generate rs232_negedge 
reg rs232_delay3;

wire rs232_negedge;

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
//  avoid the Metastable when during the receiving status
//  and generate rs232 location of negedge 
//================================================================
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rs232_delay0 <= 1'b0;
		rs232_delay1 <= 1'b0;
		rs232_delay2 <= 1'b0;
		rs232_delay3 <= 1'b0;
	end
	else begin
		// eliminate Metastable
		rs232_delay0 <= i_rs232_rxd;
		rs232_delay1 <= rs232_delay0;
		
		// generate rs232_negedge
		rs232_delay2 <= rs232_delay1;
		rs232_delay3 <= rs232_delay2;
	end
end

// instead of baud_rx_clk
assign rs232_negedge = (~rs232_delay2) & (rs232_delay3);

//================================================================
//  receiving status checking
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		receiving <= 1'b0;
	else if(o_rx_done)
		receiving <= 1'b0;
	else if(i_rx_start && rs232_negedge)
		receiving <= 1'b1;
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
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT0;
			else
				next_state = START;
		end
		BIT0: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT1;
			else
				next_state = BIT0;
		end
		BIT1: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT2;
			else
				next_state = BIT1;
		end
		BIT2: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT3;
			else
				next_state = BIT2;
		end
		BIT3: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT4;
			else
				next_state = BIT3;
		end
		BIT4: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT5;
			else
				next_state = BIT4;
		end
		BIT5: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT6;
			else
				next_state = BIT5;
		end
		BIT6: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT7;
			else
				next_state = BIT6;
		end
		BIT7: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = STOP;
			else
				next_state = BIT7;
		end
		STOP: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = IDLE;
			else
				next_state = STOP;
		end
		IDLE: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = START;
			else
				next_state = IDLE;
		end
		default: next_state = IDLE;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_reg			 <= 8'b0;
		o_data				 <= 8'b0;		
		o_rx_done			 <= 1'b0;
		o_baudrate_rx_clk_en <= 1'b0;
	end
	
	else if(receiving) begin
		o_baudrate_rx_clk_en <= 1'b1;
		if(i_baudrate_rx_clk) begin
			case(curr_state)
				IDLE: begin
					data_reg 		<= 8'b0;
					o_rx_done   	<= 1'b0;
				end     
				START: begin
					data_reg[7] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT0: begin      
					data_reg[6] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT1: begin      
					data_reg[5] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT2: begin      
					data_reg[4] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT3: begin      
					data_reg[3] 	 <= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT4: begin      
					data_reg[2] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT5: begin      
					data_reg[1] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT6: begin      
					data_reg[0] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT7: begin      
					o_rx_done   	<= 1'b0;
				end
				// STOP state have done, then pull the done signals,
				// therefore, do not make early 1 cycle in this state
				STOP: begin
					o_data			<= data_reg;
					data_reg	 	<= 8'd0;  // uart stop bit is 1 
					o_rx_done   	<= 1'b1;
				end
			endcase
		end
	end
	
	else begin
		data_reg             <= 8'd0;
		o_rx_done 			 <= 1'b0;
		o_baudrate_rx_clk_en <= 1'b0;
	end
	
end

>>>>>>> 17b668c496893641e9891cc2cdfa404909e40e7e
=======
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : uart_rxd.v
//   Module Name : uart_rxd
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module uart_rxd( // input
				clk,
				rst_n,
				i_rx_start,
				i_baudrate_rx_clk,
				i_rs232_rxd,
				
				// output
				o_data,
				o_baudrate_rx_clk_en,
				o_rx_done
				);
				
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input  clk;					        // sys_clk
input  rst_n;					    // sys_rst_n
input  i_rx_start;				    // rx signal start enable
input  i_baudrate_rx_clk;		    // rx baud clk
input  i_rs232_rxd;			    	// transfer interface

output reg [7:0] o_data;			// receiving data
output reg o_baudrate_rx_clk_en;	// rx baud clk enable
output reg o_rx_done;

//================================================================
//  Wires & Registers
//================================================================
reg receiving; 						// tell the state machine, uart is receiving
									// do not do anyting in receiving state.

reg [7:0] data_reg; 
 
reg [3:0] curr_state;
reg [3:0] next_state;

reg rs232_delay0;					// dealy 0 and 1 for eliminate metastble
reg rs232_delay1;
reg rs232_delay2;					// delay 2 and 3 for generate rs232_negedge 
reg rs232_delay3;

wire rs232_negedge;

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
//  avoid the Metastable when during the receiving status
//  and generate rs232 location of negedge 
//================================================================
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rs232_delay0 <= 1'b0;
		rs232_delay1 <= 1'b0;
		rs232_delay2 <= 1'b0;
		rs232_delay3 <= 1'b0;
	end
	else begin
		// eliminate Metastable
		rs232_delay0 <= i_rs232_rxd;
		rs232_delay1 <= rs232_delay0;
		
		// generate rs232_negedge
		rs232_delay2 <= rs232_delay1;
		rs232_delay3 <= rs232_delay2;
	end
end

// instead of baud_rx_clk
assign rs232_negedge = (~rs232_delay2) & (rs232_delay3);

//================================================================
//  receiving status checking
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		receiving <= 1'b0;
	else if(o_rx_done)
		receiving <= 1'b0;
	else if(i_rx_start && rs232_negedge)
		receiving <= 1'b1;
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
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT0;
			else
				next_state = START;
		end
		BIT0: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT1;
			else
				next_state = BIT0;
		end
		BIT1: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT2;
			else
				next_state = BIT1;
		end
		BIT2: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT3;
			else
				next_state = BIT2;
		end
		BIT3: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT4;
			else
				next_state = BIT3;
		end
		BIT4: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT5;
			else
				next_state = BIT4;
		end
		BIT5: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT6;
			else
				next_state = BIT5;
		end
		BIT6: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = BIT7;
			else
				next_state = BIT6;
		end
		BIT7: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = STOP;
			else
				next_state = BIT7;
		end
		STOP: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = IDLE;
			else
				next_state = STOP;
		end
		IDLE: begin
			if(receiving && i_baudrate_rx_clk)
				next_state = START;
			else
				next_state = IDLE;
		end
		default: next_state = IDLE;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_reg			 <= 8'b0;
		o_data				 <= 8'b0;		
		o_rx_done			 <= 1'b0;
		o_baudrate_rx_clk_en <= 1'b0;
	end
	
	else if(receiving) begin
		o_baudrate_rx_clk_en <= 1'b1;
		if(i_baudrate_rx_clk) begin
			case(curr_state)
				IDLE: begin
					data_reg 		<= 8'b0;
					o_rx_done   	<= 1'b0;
				end     
				START: begin
					data_reg[7] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT0: begin      
					data_reg[6] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT1: begin      
					data_reg[5] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT2: begin      
					data_reg[4] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT3: begin      
					data_reg[3] 	 <= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT4: begin      
					data_reg[2] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT5: begin      
					data_reg[1] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT6: begin      
					data_reg[0] 	<= i_rs232_rxd;
					o_rx_done   	<= 1'b0;
				end              
				BIT7: begin      
					o_rx_done   	<= 1'b0;
				end
				// STOP state have done, then pull the done signals,
				// therefore, do not make early 1 cycle in this state
				STOP: begin
					o_data			<= data_reg;
					data_reg	 	<= 8'd0;  // uart stop bit is 1 
					o_rx_done   	<= 1'b1;
				end
			endcase
		end
	end
	
	else begin
		data_reg             <= 8'd0;
		o_rx_done 			 <= 1'b0;
		o_baudrate_rx_clk_en <= 1'b0;
	end
	
end

>>>>>>> 39059d7608a97f01c32b431de6bb75b2ca74f4cd
endmodule