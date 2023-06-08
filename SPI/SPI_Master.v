//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : SPI_Master.v
//   Module Name : SPI_Master
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module SPI_Master(// INPUT
					sclk, 
					rst_n,
					sclk_divider,
					wr_en,
					rd_en,
					//start_addr,
					//state_init,
					rx_rd_data,
					SPI_MISO,
					
					// OUTPUT
					wr_finish,
					rd_finish,
					tx_wr_data,
					SPI_SCLK,
					SPI_CSN,
					SPI_MOSI
				  );
	
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
// INPUT
input sclk; 				// System clk
input rst_n; 				// System reset, active low
input [7:0] sclk_divider; 	// SPI clk control / divid
input wr_en;				// Write enable
input rd_en;				// Read enable
/*input [7:0] start_addr;		 Write / Read Start address*/
/*input [7:0] state_init;		 slaver state initial*/
input [7:0] tx_wr_data;		// TX Write Data
input SPI_MISO;				// SPI Master input Slave output

// OUTPUT
output wire wr_finish;		// Write finish
output wire rd_finish;		// Read finish
output wire rx_rd_data;		// RX Read Data
output wire SPI_SCLK;		// SPI CLK
output wire SPI_CSN; 		// SPI chip sel
output wire SPI_MOSI;		// SPI Master output Slave output

//================================================================
//  Wires & Registers
//================================================================
// Control
reg r_wr_en;				// Write enable
reg r_rd_en;				// Read enable

// Status
reg r_wr_finish;			// Write finish
reg r_rd_finish;			// Read finish
/*reg [7:0] r_start_addr;		 Write / Read start address*/
/*reg [7:0] r_state_init;		 slaver state initial*/
reg [1:0] r_wr_mode;		// Wrie / Read mode => 2'b01: Write / 2'b10: Read

// RX
reg [7:0] r_rx_rd_data;		// RX read Data

// SPI interface
reg r_sclk;					
reg r_sclk_d0;				// SPI clk
reg r_csn;					// SPI chip sel
reg [3:0] r_csn_cnt;		// SPI chip sel count
reg r_sclk_enable;			// SPI clk enable
reg [7:0] r_sclk_divider;	// SPI clk divider count
reg [7:0] r_wr_data;		// SPI Write Data
reg [7:0] r_spi_addr_cnt;	// SPI Write / Read address count

// State
reg [7:0] curr_state;
reg [7:0] next_state;

// clk edge
wire sclk_pedge;			// SPI clk positive edge
wire sclk_nedge;			// SPI clk negative edge

//================================================================
//  integer / genvar / parameters
//================================================================
localparam IDLE 		 = 3'd01;		// IDLE
localparam CSN_ENABLE  	 = 3'd02;		// chip sel enable 
/*localparam WRITE_INITIAL = 8'h04;		 write state initial*/
/*localparam WRITE_ADDR    = 3'd03;	 	 write address*/
localparam WRITE_DATA 	 = 3'd03;		// write data
localparam READ_DATA 	 = 3'd04;		// read data
localparam CSN_DISABLE 	 = 3'd05;		// chip sel disable
localparam FINISH 	     = 3'd06;		// finish state

//================================================================
//  input control / status
//================================================================
// read / write start
always @(posedge sclk) begin
	if(!rst_n) begin
		r_wr_en <= 1'b0;
		r_rd_en <= 1'b0;
	end
	else begin
		r_wr_en <= wr_en;
		r_rd_en <= rd_en;
	end
end

// Wrie / Read mode => 1'b0: Write / 1;b1: Read
always @(posedge sclk) begin
	if(!rst_n) begin
		r_wr_mode <= 2'b00;
	end
	else if(wr_en) begin
		r_wr_mode <= 2'b01;
	end
	else if(rd_en) begin
		r_wr_mode <= 2'b10;
	end
end

/* address
always @(posedge sclk) begin
	if(!rst_n) begin
		r_start_addr <= 8'h0;
		r_state_init <= 8'h0;
	end
	else if(wr_en | rd_en) begin
		r_start_addr <= start_addr;
		r_state_init <= state_init;
	end
end*/

//================================================================
//  Generate SPI clk
//================================================================
always @(posedge sclk) begin
	if(!rst_n) 						
		r_sclk_enable <= 1'b0;
	else if(curr_state == IDLE) 	
		r_sclk_enable <= 1'b0;
	else if(curr_state == CSN_ENABLE)
		r_sclk_enable <= 1'b1;
end

// SPI clk divider
always @(posedge sclk) begin
	if(!rst_n)
		r_sclk_divider <= 8'h0;
	else if(r_sclk_enable) begin
		if(r_sclk_divider == sclk_divider)
			r_sclk_divider <= 8'h0;
		else
			r_sclk_divider <= r_sclk_divider + 1'b1;
	end
	else 
		r_sclk_divider <= 8'h0;
end

always @(posedge sclk) begin
	if(!rst_n)
		r_sclk <= 1'b0;
	else if(r_sclk_enable) begin
		if(r_sclk_divider == sclk_divider)
			r_sclk <= ~r_sclk;
	end
	else
		r_sclk <= 1'b0;
end

always @(posedge sclk) begin
	if(!rst_n)
		r_sclk_d0 <= 1'b0;
	else
		r_sclk_d0 <= r_sclk;
end

assign sclk_pedge = (~r_sclk_d0) & r_sclk; // SPI clk positive edge
assign sclk_nedge = r_sclk_d0 & (~r_sclk); // SPI clk negative edge

//================================================================
//  SPI chip sel
//================================================================
always @(posedge sclk) begin
	if(!rst_n)
		r_csn <= 1'b1;
	else if(curr_state == CSN_DISABLE)
		r_csn <= 1'b1;
	else if((curr_state == CSN_ENABLE) & sclk_nedge)
		r_csn <= 1'b0;
end

//================================================================
//  FSM
//================================================================
always @(posedge sclk) begin
	if(!rst_n)
		curr_state <= IDLE;
	else
		curr_state <= next_state;
end

always @(*) begin
	next_state = IDLE;
	case(curr_state)
		IDLE: begin
			if(wr_en | rd_en)
				next_state = CSN_ENABLE;
			else
				next_state = IDLE;
		end
		
		// chip sel enable
		CSN_ENABLE: begin
			if(/*(r_csn_cnt == 4'h3) &*/ sclk_nedge)
				if(r_wr_mode == 2'b10)
					next_state = READ_DATA;
				else if(r_wr_mode == 2'b01)
					next_state = WRITE_DATA;
				else
					next_state = CSN_ENABLE;
			else 
				next_state = CSN_ENABLE;
		end
		
		/* slaver state initial
		WRITE_INITIAL: begin
			if((r_spi_addr_cnt[2:0] == 3'h7) & sclk_nedge)
				next_state = WRITE_ADDR;
			else
				next_state = WRITE_INITIAL;
		end*/
		
		/* write address
		WRITE_ADDR: begin
			if((r_spi_addr_cnt[2:0] == 3'h7) & sclk_nedge) begin
				if(r_wr_mode)
					next_state = READ_DATA;
				else 
					next_state = WRITE_DATA;
			end
			else 
				next_state = WRITE_ADDR;
		end*/
		
		// write data
		WRITE_DATA: begin
			if((r_spi_addr_cnt[2:0] == 3'h7) & sclk_nedge)
				next_state = CSN_DISABLE; // write finish
			else
				next_state = WRITE_DATA;
		end
		
		// read data
		READ_DATA: begin
			if((r_spi_addr_cnt[2:0] == 3'h1) & sclk_nedge)
				next_state = CSN_DISABLE; // read finish
			else 
				next_state = READ_DATA;
		end
		
		// chip disable
		CSN_DISABLE: begin
			if(/*(r_csn_cnt == 4'h3)*/ & sclk_nedge)
				next_state = FINISH;
			else 
				next_state = CSN_DISABLE;
		end
		
		// finish
		FINISH: begin
			next_state = IDLE;
		end
		
		default: begin
			next_state = IDLE;
		end
	endcase
end

always @(posedge sclk) begin
	if(!rst_n)begin
		r_spi_addr_cnt  <= 8'h0;
		r_wr_data 		<= 8'h0;
		r_rx_rd_data 	<= 8'h0;
	end
	else begin
		case(curr_state)
			IDLE: begin
				r_spi_addr_cnt  <= 8'h0;
				r_wr_data 		<= 8'h0;
				r_rx_rd_data 	<= 8'h0;
			end
			
			/* chip enable
			CSN_ENABLE: begin
				if(sclk_nedge)
					r_wr_data <= r_state_init;
			end*/
			
			CSN_ENABLE: begin
				if(sclk_nedge)
					r_wr_data <= tx_wr_data;
			end
			
			/* slaver state initial
			WRITE_INITIAL: begin
				if(sclk_nedge) begin
					if(r_spi_addr_cnt[2:0] == 3'h7) begin
						r_wr_data <= r_start_addr;
						r_spi_addr_cnt <= 8'h0;
					end
					else begin
						r_wr_data <= {r_wr_data[6:0], 1'b0};
						r_spi_addr_cnt <= r_spi_addr_cnt + 1'b1;
					end
				end
			end*/
			
			/* write address
			WRITE_ADDR: begin
				if(sclk_nedge) begin
					if(r_spi_addr_cnt[2:0] == 3'h7) begin
						r_wr_data <= rx_rd_data;
						r_spi_addr_cnt <= 8'h0;
					end
					else begin
						r_wr_data <= {r_wr_data[6:0], 1'b0};
						r_spi_addr_cnt <= r_spi_addr_cnt + 1'b1;
					end
				end
			end*/
			
			// write data
			WRITE_DATA: begin
				if(sclk_nedge) begin
					if(r_spi_addr_cnt[2:0] == 3'h7)
						r_wr_data <= r_wr_data;
					else begin
						r_wr_data <= {r_wr_data[6:0], 1'b0};
						r_spi_addr_cnt <= r_spi_addr_cnt + 1'b1;
					end
				end
			end
			
			// read data
			READ_DATA: begin
				if(sclk_pedge) begin // sample at positive edge
					r_wr_data <= 8'h0;
					r_rx_rd_data <= SPI_MISO;
					r_spi_addr_cnt <= r_spi_addr_cnt + 1'b1;
				end
			end
			
			//chip disable
			CSN_DISABLE: begin
				//do nothing
			end
			
			//finish
			FINISH: begin
				// do nothing
			end
			
			default: begin
				r_spi_addr_cnt <= 8'h0;
				r_wr_data	   <= 8'h0;
				r_rx_rd_data   <= 8'h0;
			end
		endcase
	end
end

assign rx_rd_data = (r_spi_addr_cnt[2:0] == 3'h1) ? r_rx_rd_data : 8'h0; 

//================================================================
//  SPI finish
//================================================================
always @(posedge sclk) begin
	if(!rst_n) begin
		r_wr_finish <= 1'b0;
		r_rd_finish <= 1'b0;
	end
	else begin
		r_wr_finish <= ((curr_state == FINISH) & (r_wr_mode == 2'b01));
		r_rd_finish <= ((curr_state == FINISH) & (r_wr_mode == 2'b10));
	end
end

assign wr_finish = r_wr_finish;
assign rd_finish = r_rd_finish;

//================================================================
//  SPI OUTPUT
//================================================================
assign SPI_SCLK = r_sclk;
assign SPI_CSN = r_csn;
assign SPI_MOSI = !r_csn ? r_wr_data[7] : 1'b0;

endmodule 
