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
module verset_updown_counter1 #(parameter PRESET_VALUE = 200)
		(clk,					// input clock
		resetb,					// input reset bottom
		new_cntr_preset,		// input preset signal
		new_cntr_preset_value,	// input preset value
		enable_cnt_up,			// input counting up signal
		enable_cnt_dn,			// input counting down signal
		pause_counting,			// input pause counting signal
		ctr_expired				// output counting expired signal
		);
//################################################################
input			clk;
input			resetb;
input			new_cntr_preset;
input	[7:0]	new_cntr_preset_value;
input			enable_cnt_dn;
input			enable_cnt_up;
input			pause_counting;
output			ctr_expired;
//################################################################
localparam		Idle			= 3'b000,
				//New_Preset 		= 3'b001,
				Reload			= 3'b001,
				Count_Up 		= 3'b011,
				Count_Down		= 3'b010,
				Count_Expired 	= 3'b110;
reg		[2:0]	CurrentState, NxtState;
//################################################################
reg		[1:0]	enable_cnt_up_d1;
reg		[1:0]	enable_cnt_dn_d1;
reg		[1:0]	new_cntr_preset_d1;
wire			enable_cnt_up_risedge, enable_cnt_dn_risedge, new_cntr_preset_risedge;
wire			new_preset_sig, reload_sig;

assign 	enable_cnt_up_risedge 	= enable_cnt_up_d1[0] & !enable_cnt_up_d1[1];
assign 	enable_cnt_dn_risedge 	= enable_cnt_dn_d1[0] & !enable_cnt_dn_d1[1];
assign 	new_cntr_preset_risedge = new_cntr_preset_d1[0] & !new_cntr_preset_d1[1];

assign  reload_sig 				= ((enable_cnt_up & enable_cnt_up_risedge) || (enable_cnt_dn & enable_cnt_dn_risedge)) ? 1'b1 : 1'b0;

reg		[7:0]	cnt255;
reg		[7:0]	cnt255_preset_stored;
reg 			ctr_expired;

always @(posedge clk, negedge resetb) begin
	if(!resetb) begin
		enable_cnt_up_d1 <= 2'd0;
		enable_cnt_dn_d1 <= 2'd0;
		new_cntr_preset_d1 <= 2'd0;
	end
	else begin
		enable_cnt_up_d1 <= {enable_cnt_up_d1[0],enable_cnt_up};
		enable_cnt_dn_d1 <= {enable_cnt_dn_d1[0],enable_cnt_dn};
		new_cntr_preset_d1 <= {new_cntr_preset_d1[0],new_cntr_preset};
	end
end

always @(posedge clk, negedge resetb) begin
	if(!resetb)
		CurrentState <= Idle;
	else
		CurrentState <= NxtState;
end

always @(*) begin
	NxtState = Idle;
	case(CurrentState)
	Idle:
	begin
		if (reload_sig)
			NxtState = Reload;
		else if ( enable_cnt_up)
			NxtState = Count_Up;
		else if (enable_cnt_dn)
			NxtState = Count_Down;
		else    
			NxtState = Idle;
	end
	//New_Preset:
	Reload:
	begin
		if(enable_cnt_up)
			NxtState = Count_Up;
		else if(enable_cnt_dn)
			NxtState = Count_Down;
		else
			NxtState = Reload;
	end
	Count_Up:
	begin
		if(cnt255 == cnt255_preset_stored)
			NxtState = Count_Expired;
		else
			NxtState = Count_Up;
	end
	Count_Down:
	begin
		if(cnt255 == 8'd0)
			NxtState = Count_Expired;
		else
			NxtState = Count_Down;
	end
	Count_Expired:
	begin
		NxtState = Reload;
	end
	default:
	begin
		NxtState = Idle;
	end
	endcase
end

always @(posedge clk, negedge resetb) begin
	if(!resetb) begin
		ctr_expired 			<= 1'b0;
		cnt255_preset_stored 	<= 8'd0;
		cnt255 					<= 8'd0;
		CurrentState			<= Idle;
		enable_cnt_up_d1		<= 2'd0;
		enable_cnt_dn_d1		<= 2'd0;
		new_cntr_preset_d1		<= 2'd0;
	end
	else
		case(CurrentState)
		Idle:
		begin
			if(new_cntr_preset_risedge)
				cnt255_preset_stored <= new_cntr_preset_value;
			else
				cnt255_preset_stored <= cnt255_preset_stored;
		end
		Reload:
		begin
			ctr_expired <= 0;
			case(1'b1)
			enable_cnt_dn: 	cnt255 <= cnt255_preset_stored;
			enable_cnt_up: 	cnt255 <= 8'd0;
			default:		cnt255 <= cnt255;
			endcase

		end
		Count_Up:
			if(pause_counting)
				cnt255 <= cnt255;
			else
				cnt255 <= cnt255 + 1'b1;
		Count_Down:
			if(pause_counting)
				cnt255 <= cnt255;
			else
				cnt255 <= cnt255 - 1'b1;
		Count_Expired:
			ctr_expired <= 1'b1;
		default:
			begin
				ctr_expired 			<= 1'b0;
				cnt255_preset_stored 	<= 8'd0;
				cnt255 					<= 8'd0;
				//CurrentState			<= Idle;
				enable_cnt_up_d1		<= 2'd0;
				enable_cnt_dn_d1		<= 2'd0;
				new_cntr_preset_d1		<= 2'd0;
			end
		endcase
end

endmodule
