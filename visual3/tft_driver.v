`timescale 1ns / 1ps
`default_nettype none

`define TFT_X_RES 480 //pixel clock periods
`define TFT_Y_RES 272 //frame lines
`define TFT_X_BLANKING 45 //pixel clock periods
`define TFT_Y_BLANKING 16 //frame lines
`define TFT_CLK_DIV_COUNT 5 
`define TFT_BITS_PER_COLOR 3  //512 colors
`define TFT_BITS_PER_PIXEL 9
`define TFT_X_NUM_BITS 12
`define TFT_Y_NUM_BITS 12

// wr_ena should be the old locked_touch_z in main
module tft_driver(
	input wire cclk, rstb,
	input wire tft_clk,
	output wire tft_backlight, tft_data_ena,
	output reg tft_display, tft_vdd,
	output wire [7:0] tft_red, tft_green, tft_blue,
    
	input wire wr_ena,  // write enable signal for video RAM. Active high. This should only be high if the screen is being touched.
    input wire clear_screen,  // Tells the tft_driver to clear the screen. Input is received from a button pressed on the FPGA.
	output reg clear_done,  // Tells the main module that the clear process is complete.
	input wire [11:0] wr_x,  // x coordinate of the point currently being touched.
	input wire [11:0] wr_y,  // y coordinate of the point currently being touched.
	input wire [(`TFT_BITS_PER_PIXEL-1):0] wr_data,  // Data to be written to the video RAM. This corresponds to the color of the line that will be drawn.
    
    // Same as from Visual 1 and 2.
	output reg [(`TFT_X_NUM_BITS-1):0] x,
	output reg [(`TFT_Y_NUM_BITS-1):0] y,
	output wire new_frame
);

// Video memory read and write addresses. They will be assigned values from the tft_address_generator modules.
wire [16:0] video_ram_wr_addr, video_ram_rd_addr, wr_addr;

// If we are not writing to the video RAM, this should be low.
wire video_ram_wr_ena;

// This creates addresses from x and y coordinates. It has already been written for you.
tft_address_generator TFT_ADDR_0 (.x(wr_x), .y(wr_y), .addr(wr_addr));
tft_address_generator TFT_ADDR_1 (.x(x[8:0]), .y(y), .addr(video_ram_rd_addr));

// You need to separate the RGB components from color and assign values to tft_red/green/blue accordingly.
wire [(`TFT_BITS_PER_PIXEL-1):0] color;

assign tft_red  [`TFT_BITS_PER_PIXEL - 1:`TFT_BITS_PER_PIXEL - 3] = color[8:6];
assign tft_red [`TFT_BITS_PER_PIXEL - 4:0] = 0;
assign tft_green [`TFT_BITS_PER_PIXEL - 1:`TFT_BITS_PER_PIXEL - 3] = color[5:3];
assign tft_green [`TFT_BITS_PER_PIXEL - 4:0] = 0;
assign tft_blue [`TFT_BITS_PER_PIXEL - 1:`TFT_BITS_PER_PIXEL - 3] = color[2:0];
assign tft_blue [`TFT_BITS_PER_PIXEL - 4:0] = 0;

// This value will be written to the video RAM. It needs to be set based on whether we are clearing the screen or if we are writing a new value to the RAM.
reg [(`TFT_BITS_PER_PIXEL-1):0] video_ram_wr_data;

<<<<<<< HEAD
assign video_ram_wr_addr = wr_addr;
assign video_ram_wr_ena = wr_ena && (current_state == `ACTIVE);

=======
>>>>>>> 70029fea25a7023868973482f1b150d8a4c1641b
coregen_video_ram VRAM(
	.clka(cclk), .clkb(tft_clk),
	.wea(video_ram_wr_ena), 
	.addra(video_ram_wr_addr),
	.dina(video_ram_wr_data),
	.addrb(video_ram_rd_addr), 
	.doutb(color),
    // This is a dual port memory structure, so it can read and write two values to two different addresses simultaneously. We won't be using this feature.
	.web(1'b0),
	.dinb(9'b0)	
);

// Make pwm generator
wire pwm_output;
wire [31:0] frequency_division, duty_cycle;
assign frequency_division = 32'd255;
assign duty_cycle = 32'd128;

pwm_generator PWM_MACHINE (
				   .cclk(tft_clk), 
				   .rstb(rstb), 
				   .frequency_division(frequency_division), 
				   .duty_cycle(duty_cycle), 
				   .pwm(pwm_output)
			  );
assign tft_backlight = pwm_output; // Apply your PWM output here for dimness.

/* You will need to write an FSM to clear the screen when the clear_screen input is received. That can go here.

The clear_screen button may be released before the screen is actually fully cleared, but that should not stop the clearing process! You may need to create additional wires and registers to ensure that the screen clear works correctly.
*/

// These will define the boundaries of the rectangle you will display.
wire [11:0] rect_x_min, rect_x_max, rect_y_min, rect_y_max;

// Combinational logic assignments
assign rect_x_min = 12'd0;
assign rect_x_max = 12'd525;
assign rect_y_min = 12'd0;
assign rect_y_max = 12'd288;

// Combinatinonal logic
wire valid_x, valid_y, is_blue, is_orange, row_end, column_end;
assign valid_x = (x < `TFT_X_RES) && (x > rect_x_min);
assign valid_y = (y < `TFT_Y_RES) && (y > rect_y_min);
assign row_end = (x == rect_x_max);
assign column_end = (y == rect_y_max);

// State Flags
wire active, frame_end, next_row;
assign active = valid_x && valid_y;
assign frame_end = column_end;
assign next_row = row_end && ~column_end;
assign current_state = {frame_end, next_row, active};

always @(posedge tft_clk) begin
	if (~rstb) begin
		x <= 0;
		y <= 0;
		tft_vdd <= 0;
		tft_display <= 0;
		clear_done <= 0;
		video_ram_wr_data <= 0;
	end
	else begin
		tft_vdd <= 1'd1;
		tft_display <= 1'd1;
		case (current_state)
			`PORCH: begin 
				x <= x + 12'd1;
			end
			`ACTIVE: begin 
				x <= x + 12'd1
				if( x == wr_x && y == wr_y) begin
					video_ram_wr_data <= 12'hffffff;
				end
				else if (~clear_screen) begin
					video_ram_wr_data <= 12'hff0000;
				end
				else begin
					video_ram_wr_data <= 12'h0000ff;
				end
			end
			`ROW_ENDING: begin
				x <= 12'd0;
				y <= y + 12'd1;
			end
			`COLUMN_ENDING: begin
				x <= 12'd0;
				y <= 12'd0;
			end
		endcase
	end
end

/* Insert the relevant pieces of your code from Lab 3 Visual 2 here. */


endmodule
`default_nettype wire
