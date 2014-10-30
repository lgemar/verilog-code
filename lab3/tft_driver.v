`timescale 1ns / 1ps
`default_nettype none

`define TFT_X_RES 480 //pixel clock periods
`define TFT_Y_RES 272 //frame lines
`define TFT_X_BLANKING 45 //pixel clock periods
`define TFT_Y_BLANKING 16 //frame lines
`define TFT_CLK_DIV_COUNT 5 
`define TFT_BITS_PER_COLOR 3  //512 colors
`define TFT_BITS_PER_PIXEL 8
`define TFT_X_NUM_BITS 10
`define TFT_Y_NUM_BITS 9
`define RECT_SIZE 25

module tft_driver(
	input wire cclk, // Not needed yet, but will need later.
    input wire rstb,
	input wire tft_clk,
	input wire [31:0] frequency_division, 
	input wire [7:0] duty_cycle,
    input wire [11:0] touch_x, touch_y,
	output wire tft_backlight, tft_data_ena,
	output reg tft_display,tft_vdd,
	output wire [7:0] tft_red, tft_green, tft_blue,
	output reg [(`TFT_X_NUM_BITS-1):0] x,
	output reg [(`TFT_Y_NUM_BITS-1):0] y,
	output wire new_frame
);

// RGB pixel values.
wire [(`TFT_BITS_PER_COLOR-1):0] r, g, b;

// These will define the boundaries of the rectangle you will display.
wire [9:0] rect_x_min, rect_x_max, rect_y_min, rect_y_max;
// These are the center coordinates of the rectangle.
wire [11:0] rect_x, rect_y, rect_width;

assign rect_x = touch_x; // Pick a value for this.
assign rect_y = touch_y; // Pick a value for this too.
assign rect_width = 12'd50;
// Fill in this code. The min and max values should extend RECT_SIZE pixels above, below, 
// left, and right of the center. You can use some behavioral Verilog here.
// Take care that they don't go negative!
assign rect_x_min = 10'd0;
assign rect_x_max = 10'd525;
assign rect_y_min = 10'd0;
assign rect_y_max = 10'd288;

// Combinational logic
wire valid_x, valid_y, is_blue, is_orange, row_end, column_end;
assign valid_x = (x < rect_x_max) && (x > rect_x_min);
assign valid_y = (y < rect_y_max) && (y > rect_y_min);
assign is_blue = (x > (rect_x - rect_width)) && (x < rect_x + rect_width)
			     && (y > rect_y - rect_width) && (y < rect_y + rect_width);
assign is_orange = valid_x && valid_y && ~is_blue;
assign row_end = (x == rect_x_max);
assign column_end = (y == rect_y_max);

// State Flags
wire active, frame_end, next_row;
assign active = valid_x && valid_y;
assign frame_end = column_end;
assign next_row = row_end && ~column_end;

// Pick your colors. Remember that you have to draw a blue square on an orange background. 
// You can use some behavioral Verilog here. Hint: the >, <, and ? operators will be very handy.
assign b = is_blue ? (active & 3'd7) : (is_orange & 3'd0);
assign r = is_blue ? (active & 3'd0) : (is_orange & 3'd7);
//assign r = is_blue ? (active & {3{tft_button}}) : (is_orange & 3'd7);
assign g = is_blue ? (active & 3'd0) : (is_orange & 3'd5);

// Signal that a new frame is coming when y has finished counting to the end of the vertical porch region.
assign new_frame = frame_end;

// Make pwm generator
wire pwm_output;
pwm_generator PWM_MACHINE (
				   .cclk(tft_clk), 
				   .rstb(rstb), 
				   .frequency_division(frequency_division), 
				   .duty_cycle(duty_cycle), 
				   .pwm(pwm_output)
			  );
assign tft_backlight = pwm_output; // Apply your PWM output here for dimness.

// Use combinational logic here to determine when this enable signal should be high and low.
// It should be based the values of x and y. Behavioral Verilog can and should be used here too.
assign tft_data_ena = active;

// We chose TFT_BITS_PER_COLOR bit values for R, G, and B, but the screen uses 8 bit values for each component.
// To translate between the two representations, set the upper TFT_BITS_PER_COLOR bits of the tft pixel values
// to R, G, B, and all the lower order bits to 0.
// Remember that if the enable signal is low, ALL bits should be zero!
// Example: if r = 011 and tft_data_ena = 1, the tft_red = 0110000.
// Be sure to use the constants like TFT_BITS_PER_COLOR, instead of hardcoding the values!
// Note: feel free to add more lines of code here...we're not constraining you to what we have provided.
assign tft_red  [`TFT_BITS_PER_PIXEL - 1:`TFT_BITS_PER_PIXEL - 3] = r & {3{active}};
assign tft_red [`TFT_BITS_PER_PIXEL - 4:0] = 0;
assign tft_green [`TFT_BITS_PER_PIXEL - 1:`TFT_BITS_PER_PIXEL - 3] = g & {3{active}};
assign tft_green [`TFT_BITS_PER_PIXEL - 4:0] = 0;
assign tft_blue [`TFT_BITS_PER_PIXEL - 1:`TFT_BITS_PER_PIXEL - 3] = b & {3{active}};
assign tft_blue [`TFT_BITS_PER_PIXEL - 4:0] = 0;

`define PORCH 3'b000
`define ACTIVE 3'b001
`define ROW_ENDING 3'b010
`define COLUMN_ENDING 3'b100

always @(posedge tft_clk) begin
	/* Insert your FSM code to count x and y and set any other outputs needed. */
	if (~rstb) begin
		x <= 0;
		y <= 0;
		tft_vdd <= 0;
		tft_display <= 0;
	end
	else begin
		tft_vdd <= 1;
		tft_display <= 1;
		case ({frame_end, next_row, active})
			`PORCH: x <= x + 1;
			`ACTIVE: x <= x + 1;
			`ROW_ENDING: begin
				x <= 0;
				y <= y + 1;
			end
			`COLUMN_ENDING: begin
				x <= 0;
				y <= 0;
			end
		endcase
	end
end

endmodule
`default_nettype wire
