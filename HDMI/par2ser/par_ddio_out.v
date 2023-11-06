module DDIO_OUT #( parameter WIDTH = 1)
(
    datain_h,				// posedge data
    datain_l,				// negedge data
    clk,					// sys_clk
    clk_en,					// sys_clk en
    aclr,					// asyn clear data to 0
    aset,					// asyn set data to 1
    oe,						// output data enable
    sclr,					// syn clear data to 0
    sset,                   // syn set data to 1
    dataout,				// output data
    oe_out					// output data enabl signal
);

//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input		[WIDTH-1:0] datain_h;	// posedge data
input		[WIDTH-1:0] datain_l;	// negedge data
input		clk;					// sys_clk
input		clk_en;					// sys_clk en
input		aclr;					// asyn clear data to 0
input		aset;					// asyn set data to 1
input		oe;						// output data enable
input		sclr;					// syn clear data to 0
input		sset;                   // syn set data to 1
output wire [WIDTH-1:0] dataout;	// output data
output wire oe_out;					// output data enabl signal


//================================================================
//  Wires & Registers
//================================================================
reg [WIDTH-1:0] dataout_reg;
reg [WIDTH-1:0] datain_l_r1;
reg [WIDTH-1:0] datain_l_r2;
reg oe_p;
reg oe_n;


//================================================================
//  posedge data enable and negedge data enable logic
//================================================================
always @(posedge clk or negedge aclr or negedge aset) begin
	if (!aclr) begin
		oe_p <= 1'b0;
		oe_n <= 1'b0;
	end
	else if(oe) begin
		oe_p <= oe;
		oe_n <= ~oe;
	end
	else begin
		oe_p <= 1'b0;
		oe_n <= 1'b0;
	end	
end

always @(negedge clk or negedge aclr or negedge aset) begin
	if (!aclr) begin
		oe_p <= 1'b0;
		oe_n <= 1'b0;
	end
	else if(oe) begin
		oe_n <= oe;
		oe_p <= ~oe;
	end
	else begin
		oe_p <= 1'b0;
		oe_n <= 1'b0;
	end	
end


//================================================================
//  Asyn and Syn Clear and Set
//================================================================
/* Asyn and Syn, only one type can be choosen */ 
always @(posedge clk or negedge aclr or negedge aset) begin	
    if (!aclr) begin
        dataout_reg <= 'b0;
    end 
	else if (!aset) begin
        dataout_reg <= 'b1;
    end 
	else if (sclr) begin
        dataout_reg <= 'b0;
    end 
	else if (sset) begin
        dataout_reg <= 'b1;
    end 
	/*else if (clk_en & oe_p) begin
        dataout_reg <= datain_h;
    end*/
end

//================================================================
//  To satisfy negedge output data, that need to delay 1 clk time
//================================================================
always @(negedge clk) begin
	datain_l_r1 <= datain_l;
	datain_l_r2 <= datain_l_r1;	
end

//================================================================
//  Data output
//================================================================
assign dataout = oe ? (oe_p ? datain_h : (oe_n ? datain_l : 8'd0)) : dataout_reg;
assign oe_out  = oe; 

endmodule
