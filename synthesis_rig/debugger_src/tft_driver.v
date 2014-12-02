`timescale 1ns / 1ps
`default_nettype none
`include "tft_defines.v"

module tft_driver(
	input wire tft_clk, rstb,
	output wire tft_backlight, tft_data_ena,
	output reg tft_display,tft_vdd,
	output wire [7:0] tft_red, tft_green, tft_blue,
	input wire [(`TFT_BITS_PER_PIXEL-1):0] color,
	output reg [(`TFT_X_NUM_BITS-1):0] x,
	output reg [(`TFT_Y_NUM_BITS-1):0] y,
	output wire new_frame
);

wire blanking;
reg [2:0] clk_div_counter;
wire [(`TFT_BITS_PER_COLOR-1):0] r, g, b;

assign r = color[(3*`TFT_BITS_PER_COLOR-1):(2*`TFT_BITS_PER_COLOR)];
assign g = color[(2*`TFT_BITS_PER_COLOR-1):`TFT_BITS_PER_COLOR];
assign b = color[(`TFT_BITS_PER_COLOR-1):0];

assign new_frame = (y == `TFT_Y_RES) && (x == `TFT_X_RES);
assign tft_backlight = 1; //pwm this for dimness

assign tft_data_ena = (x <= `TFT_X_RES) & (y <= `TFT_Y_RES);

assign tft_red[7:(8-`TFT_BITS_PER_COLOR)]   = (tft_data_ena) ? r : `TFT_BITS_PER_COLOR'b0;
assign tft_green[7:(8-`TFT_BITS_PER_COLOR)] = (tft_data_ena) ? g : `TFT_BITS_PER_COLOR'b0;
assign tft_blue[7:(8-`TFT_BITS_PER_COLOR)]  = (tft_data_ena) ? b : `TFT_BITS_PER_COLOR'b0;

always @(posedge tft_clk) begin
	if(~rstb) begin
		tft_display <= 0;
		tft_vdd <= 0;
		x <= 0;
		y <= 0;
	end
	else begin
		tft_display <= 1;
		tft_vdd <= 1;
		if(x < (`TFT_X_RES + `TFT_X_BLANKING)) begin
			x <= x + 10'd1;
		end
		else begin
			x <= 10'd0;
			if (y < (`TFT_Y_RES + `TFT_Y_BLANKING)) begin
				y <= y + 9'd1;
			end
			else begin
				y <= 9'd0;
			end
		end
	end
end

endmodule
`default_nettype wire
