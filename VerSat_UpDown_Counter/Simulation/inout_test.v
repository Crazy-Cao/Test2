// *********************************************************************************
// Project Name : 
// Email        : 
// Website      : 
// Create Time  : 201// 
// File Name    : .v
// Module Name  : 
// Abstract     :
// editor		: sublime text 3
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 201//    Crazy Cao           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns
module inout_test
(
	input	wire		clk,
	input	wire		reset,
	inout   wire		testline,
	input	wire		rd,
	input	wire		wr,
	output  wire		monitor
);

reg			data_in, data_out;
reg	[7:0]	test_counter;
//reg 		inout_en;
wire[7:0]	test_counter_next;

assign 	test_counter_next = (test_counter == 200) ? 'd0 : (test_counter + 1'b1);

always @(posedge clk, negedge reset) begin
	if(!reset)
		test_counter <= 'd0;
	else 
		test_counter <= test_counter_next;
end



always @(posedge clk, negedge reset) begin
	if(!reset) begin
		data_out <= 0;
		data_in  <= 0;
	end
	else if(rd)
		data_out 	<= test_counter[1];
	else
		data_in		<= testline;
end

assign testline = (rd) ? data_out : 1'bz;
assign monitor  = data_in & (wr);

endmodule


module testbench_inout();

reg clk;
reg reset;
reg dout;
wire rd;
wire wr;

reg [7:0] test_cntr;

wire  din;
wire  dout_l;

assign  dout_l = (wr) ? test_cntr[2] : 1'bz;
assign  rd = test_cntr[4];
assign  wr = ~rd;

initial begin
	clk = 0;
	reset = 0;
	dout = 0;
	//rd   = 0;
	//wr   = 0;
	test_cntr = 0;
	#20 reset = 1;
end

always #5 clk = ~clk;

always @(posedge clk, negedge reset) begin
	if(!reset)
		test_cntr <= 0;
	else if(test_cntr >= 100)
		test_cntr <= 0;
	else
		test_cntr <= test_cntr + 1;
		
end

inout_test testunit
(
	.clk(clk),
	.reset(reset),
	.rd(rd),
	.wr(wr),
	.testline(dout_l),
	.monitor(din)
);

endmodule