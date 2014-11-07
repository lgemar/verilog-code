`timescale 1ns / 1ps
`default_nettype none

`define TOUCH_CLK_DIV_COUNT 25
`define TOUCH_READ_X       2'b00
`define TOUCH_READ_Y       2'b01
`define TOUCH_READ_Z       2'b10
`define TOUCH_READ_INVALID 2'b11

//fsm states
`define TOUCH_STATE_RESET      0
`define TOUCH_STATE_TX_START   1
`define TOUCH_STATE_TXING      2
`define TOUCH_STATE_BUSY       3
`define TOUCH_STATE_RXING      4
`define TOUCH_STATE_RX_DONE    5
`define TOUCH_STATE_RX_WAIT    6

`define TOUCH_X_ADJ_MIN 12'h090
`define TOUCH_X_POST_ADJ_MAX 12'h745

`define TOUCH_Y_ADJ_MIN 12'h060
`define TOUCH_Y_POST_ADJ_MAX 12'h6F0

module touchpad_controller(
	input wire cclk, rstb,
	input wire touch_busy,data_in,
	output reg touch_clk, data_out,
	output reg touch_csb,
	output reg [8:0] x,y,z
);

reg [4:0] clk_div_counter;

always @(posedge cclk) begin
	if(~rstb) begin
		clk_div_counter <= 0;
	end
	else begin
		touch_csb <= 0;
		if(clk_div_counter != (`TOUCH_CLK_DIV_COUNT-1)) begin
			clk_div_counter <= clk_div_counter + 6'd1;
		end
		else begin
			clk_div_counter <= 0;
			touch_clk <= ~touch_clk;
			if(touch_clk) begin  //negative edge logic
				/* PUT ALL CODE HERE FOR NEGATIVE EDGE FSM LOGIC! */
			end
		end
	end
end

endmodule
`default_nettype wire
