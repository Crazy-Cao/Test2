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
/*
module verset_updown_counter #(parameter PRESET_VALUE = 200)
		(clk,					// input clock
		resetb,					// input reset bottom
		new_cntr_preset,		// input preset signal
		new_cntr_preset_value,	// input preset value
		enable_cnt_up,			// input counting up signal
		enable_cnt_dn,			// input counting down signal
		pause_counting,			// input pause counting signal
		ctr_expired				// output counting expired signal
		);
*/

module top_test();
reg clk;
reg resetb;
reg new_cntr_preset;
reg [7:0] new_cntr_preset_value;
reg enable_cnt_dn;
reg enable_cnt_up;
reg pause_counting;
wire ctr_expired;
wire ctr_expired2;

initial
begin
	clk = 0;
	resetb = 1;
	new_cntr_preset = 0;
	new_cntr_preset_value = 8'd0;
	enable_cnt_dn = 0;
	enable_cnt_up = 0;
	pause_counting = 0;
	#5 resetb = 0;
	#5 resetb = 1;
	#10 new_cntr_preset_value = 8'd10;
	new_cntr_preset = 1;
	#5 enable_cnt_up = 1;
	#20 pause_counting = 1;
	#30 pause_counting = 0;
	#50 enable_cnt_up = 0;
	enable_cnt_dn = 1;
	#20 pause_counting = 1;
	#30 pause_counting = 0;
end

always #1 clk = ~clk;

verset_updown_counter1 test_u(
					.clk(clk),
					.resetb(resetb),
					.new_cntr_preset(new_cntr_preset),
					.new_cntr_preset_value(new_cntr_preset_value),
					.enable_cnt_up(enable_cnt_up),
					.enable_cnt_dn(enable_cnt_dn),
					.pause_counting(pause_counting),
					.ctr_expired(ctr_expired));

verset_updown_counter2 test_u2(
					.clk(clk),
					.resetb(resetb),
					.new_cntr_preset(new_cntr_preset),
					.new_cntr_preset_value(new_cntr_preset_value),
					.enable_cnt_up(enable_cnt_up),
					.enable_cnt_dn(enable_cnt_dn),
					.pause_counting(pause_counting),
					.ctr_expired(ctr_expired2));
endmodule