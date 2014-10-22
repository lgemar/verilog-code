`timescale 1ns / 1ps

`default_nettype none //makes undeclared nets errors instead of automatic wires

module main(
	//default IO
	input wire unbuf_clk, rstb,
	input wire [7:0] switch,
	output wire [7:0] led,
	output wire [7:0] JB,
	input wire button_up, button_down, button_right, button_left, button_center,
	//tft IO
	output wire tft_backlight, tft_clk, tft_data_ena,
	output wire tft_display,tft_vdd,
	output wire [7:0] tft_red, tft_green, tft_blue
);

//clocking signals
wire cclk, cclk_n, tft_clk_buf, tft_clk_buf_n, clocks_locked;
wire reset;
assign reset = ~rstb;

//tft signals
wire [9:0] tft_x;
wire [8:0] tft_y;
wire tft_new_frame;

//debugging signals
//feel free to connect signals here so that you can probe/see them
assign led = 0; 
assign JB = 8'b0; 

//generate all the clocks
clock_generator CLOCK_GEN (.clk_100M_in(unbuf_clk), .CLK_100M(cclk), .CLK_100M_n(cclk_n), .CLK_9M(tft_clk_buf), .CLK_9M_n(tft_clk_buf_n), .RESET(reset), .LOCKED(clocks_locked));
//pass the tft_clk through a DDR2 output buffer (so that it can drive external loads and so that internal loads are unaffected by large skew routing)
ODDR2 tft_clk_fixer (.D0(1'b1), .D1(1'b0), .C0(tft_clk_buf), .C1(tft_clk_buf_n), .Q(tft_clk), .CE(1'b1));

tft_driver TFT(
	.cclk(cclk),
	.rstb(rstb),
	.tft_backlight(tft_backlight),
	.tft_clk(tft_clk_buf),
	.tft_data_ena(tft_data_ena),
	.tft_display(tft_display),
	.tft_vdd(tft_vdd),
	.tft_red(tft_red),
	.frequency_division(32'd255), 
	.duty_cycle(switch), 
	.tft_green(tft_green),
	.tft_blue(tft_blue),
	.x(tft_x), .y(tft_y),
	.new_frame(tft_new_frame)
);
	initial begin 
		// Insert the dumps here
		$dumpfile("alu_and_test.vcd");
		$dumpvars(0, alu_and_test);
		// Initialize Inputs
		i = 32'h0x0;
		A = 32'h0x0;
		B = 32'h0x0;
		// Wait 100 ns for global reset to finish
		#100;
		// Add stimulus here
		for (i = 0; i < 16; i = i + 1) begin
			#100;
			A = i;
			B = ~i;
			$display("Inputs: %b, %b ; Output: %b", A, B, Z);
		end
		$finish;
	end
endmodule

`default_nettype wire //disable default_nettype so non-user modules work properly
