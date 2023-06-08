//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : baudrate_gen.v
//   Module Name : baudrate_gen
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module baudrate_gen( // input
					 clk,
					 rst_n,
					 I_baudrate_tx_clk_en,
					 I_baudrate_rx_clk_en,
					 // ouput
					 O_baudrate_tx_clk,
					 O_baudrate_rx_clk
					 );
					 
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input  clk, rst_n;
input  I_baudrate_tx_clk_en;
input  I_baudrate_rx_clk_en;

output O_baudrate_tx_clk;
output O_baudrate_rx_clk;

//================================================================
//  parameters & integer
//================================================================
//*************************** intro ****************************//
// system clk is 50MHz => 20ns. if take baud9600 the cycle      //
// period is (1/9600) / 20ns = 5207 							//
//*************************** intro ****************************//
parameter C_baud9600   = 5207; 				// baud = 9600
parameter C_baud19200  = 2603;              // baud = 19200
parameter C_baud38400  = 1304;              // baud = 38400
parameter C_baud57600  = 867;               // baud = 57600
parameter C_baud115200 = 433;               // baud = 115200

parameter C_baud_sel = C_baud115200;			// baud sel

//================================================================
//  Wires & Registers
//================================================================
reg [13:0] baud_tx_cnt;
reg [13:0] baud_rx_cnt;

//================================================================
//  UART_TX module clk generate 
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		baud_tx_cnt <= 13'd0;
	else if(I_baudrate_tx_clk_en) begin
		if(baud_tx_cnt == C_baud_sel)
			baud_tx_cnt <= 13'd0;
		else
			baud_tx_cnt <= baud_tx_cnt + 1'b1;
	end
	else
		baud_tx_cnt <= 13'd0;
	
end

assign O_baudrate_tx_clk = (baud_tx_cnt == 13'd1) ? 1'b1 : 1'b0;

//================================================================
//  UART_RX module clk generate 
//================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		baud_rx_cnt <= 13'd0;
	else if(I_baudrate_rx_clk_en) begin
		if(baud_rx_cnt == C_baud_sel)
			baud_rx_cnt <= 13'd0;
		else
			baud_rx_cnt <= baud_rx_cnt + 1'b1;
	end
	else
		baud_rx_cnt <= 13'd0;
	
end

assign O_baudrate_rx_clk = (baud_rx_cnt == C_baud_sel >> 1'b1) ? 1'b1 : 1'b0;

endmodule