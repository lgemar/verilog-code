`timescale 1ns / 1ps
`default_nettype none

`define TFT_X_RES 480 //pixel clock periods
`define TFT_Y_RES 272 //frame lines
`define TFT_X_BLANKING 45 //pixel clock periods
`define TFT_Y_BLANKING 16 //frame lines
`define TFT_CLK_DIV_COUNT 5 
`define TFT_BITS_PER_COLOR 3  //512 colors
`define TFT_BITS_PER_PIXEL 9
`define TFT_X_NUM_BITS 10
`define TFT_Y_NUM_BITS 9
`define RECT_SIZE 25

module tft_driver(
	input wire cclk, rstb,
	input wire tft_clk,
	output wire tft_backlight, tft_data_ena,
	output reg tft_display,tft_vdd,
	output wire [7:0] tft_red, tft_green, tft_blue,
	input wire [8:0] touch_x,
	input wire [8:0] touch_y,
	input wire [(`TFT_BITS_PER_PIXEL-1):0] wr_data,
	output reg [(`TFT_X_NUM_BITS-1):0] x,
	output reg [(`TFT_Y_NUM_BITS-1):0] y,
	output wire new_frame
);

/*
Copy your module from the previous week here!
*/

endmodule
`default_nettype wire