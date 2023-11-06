`timescale 1ns/10ps

`include "ddio_out.v"

module tb_DDIO_OUT;

reg [7:0] datain_h;
reg [7:0] datain_l;
reg clk;
reg clk_en;
reg aclr;
reg aset;
reg oe;
reg sclr;
reg sset;
wire [7:0] dataout;
wire oe_out;

//================================================================
//  Instantiation 
//================================================================
DDIO_OUT dut (
    .datain_h	(datain_h					),
    .datain_l	(datain_l					),
    .clk		(clk						),
    .clk_en		(clk_en						),
    .aclr		(aclr						),
    .aset		(aset						),
    .oe			(oe							),
    .sclr		(sclr						),
    .sset		(sset						),
    .dataout	(dataout					),
    .oe_out		(oe_out						)
);

//================================================================
//  Clock gen                         
//================================================================
always #10 clk = ~clk;

//================================================================
//  Random input data generate                         
//================================================================
always #20 datain_h = $random % 256;
always #20 datain_l = $random % 256;

initial begin
	$dumpfile("DDIO_OUT.vcd");
	$dumpvars();
end


initial begin
	clk_en 		= 1'b1;
    clk  		= 1'b0;
	aclr 		= 1'b0;
				
	oe   		= 1'b0;
    datain_h	= 8'd0;
    datain_l	= 8'd0;
        
	#35
	aclr 		= 1'b1;
		
	#10
	oe 			= 1'b1;
    
	#200    
    oe			= 1'b0;

    #50 $finish;
end

endmodule
