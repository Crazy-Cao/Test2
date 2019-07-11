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
module verset_updown_counter2
		(clk,
		resetb,
		new_cntr_preset,
		new_cntr_preset_value,
		enable_cnt_up,
		enable_cnt_dn,
		pause_counting,
		ctr_expired);
//##############################################################################
input				clk;
input				resetb;
input				new_cntr_preset;
input	[7:0]		new_cntr_preset_value;
input				enable_cnt_dn;
input				enable_cnt_up;
input				pause_counting;
output				ctr_expired;
reg		[7:0]		count255, count255_nxt;
reg		[7:0]		cnt_preset_stored;
wire		[7:0]		cnt_preset_stored_nxt;
reg					ctr_expired;
wire				ctr_expired_nxt, cnt_up_expired, cnt_dn_expired;
reg		[1:0]		enable_cnt_dn_d1, enable_cnt_up_d1;
wire				enable_cnt_up_risedge, enable_cnt_dn_risedge;

//############################################################################
assign enable_cnt_dn_risedge = !enable_cnt_dn_d1[1] & enable_cnt_dn_d1[0];
assign enable_cnt_up_risedge = !enable_cnt_up_d1[1] & enable_cnt_up_d1[0];

assign cnt_preset_stored_nxt = (new_cntr_preset) ? new_cntr_preset_value: cnt_preset_stored;

assign cnt_up_expired  = (count255_nxt == cnt_preset_stored) ? 1'b1 : 1'b0;
assign cnt_dn_expired  = (count255_nxt == 'd0) ? 1'b1 : 1'b0;
assign ctr_expired_nxt = (enable_cnt_up) ? cnt_up_expired :
											((enable_cnt_dn)? cnt_dn_expired : 1'b0);

always @(*) begin
	count255_nxt = count255;

	if(enable_cnt_dn_risedge)
		count255_nxt	= cnt_preset_stored;
	else if(enable_cnt_up_risedge)
		count255_nxt	= 'd0;
	else if(pause_counting)
		count255_nxt	= count255;
	else if(enable_cnt_dn && ctr_expired)
		count255_nxt	= cnt_preset_stored;
	else if(enable_cnt_dn)
		count255_nxt	= count255 - 1'b1;
	else if(enable_cnt_up && ctr_expired)
		count255_nxt	= 'd0;
	else if(enable_cnt_up)
		count255_nxt	= count255 + 1'b1;
end

always @(posedge clk or negedge resetb) begin
	if(!resetb) begin
		count255 			<= 'd0;
		cnt_preset_stored 	<= 'd0;
		ctr_expired 		<= 1'b0;
		enable_cnt_up_d1 	<= 2'd0;
		enable_cnt_dn_d1	<= 2'd0;
	end
	else begin
		count255 			<= count255_nxt;
		cnt_preset_stored 	<= cnt_preset_stored_nxt;
		ctr_expired 		<= ctr_expired_nxt;
		enable_cnt_dn_d1 	<= {enable_cnt_dn_d1[0], enable_cnt_dn};
		enable_cnt_up_d1    <= {enable_cnt_up_d1[0], enable_cnt_up};
	end
end

endmodule