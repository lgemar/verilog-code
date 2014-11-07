`timescale 1ns / 1ps
`default_nettype none

module tft_address_generator(
	input wire [8:0] x,
	input wire [8:0] y,
	output wire [16:0] addr
);

wire [8:0] clamped_x;
wire [8:0] clamped_y;
assign clamped_x = (x > 9'd479) ? 9'd479 : x;
assign clamped_y = (y > 9'd271) ? 9'd271 : y;

wire [16:0] x_times_256;
wire [16:0] x_times_16;
assign x_times_256 = clamped_x << 8;
assign x_times_16 = clamped_x << 4;
assign addr = x_times_256 + x_times_16 - x + clamped_y;

endmodule
`default_nettype wire