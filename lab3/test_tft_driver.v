`timescale 1ns / 1ps

`default_nettype none //makes undeclared nets errors instead of automatic wires

module test_tft_driver;

// Color outputs
wire [7:0] tft_red, tft_green, tft_blue;
// Color flags
reg [1:0] color;
// Clocking inputs
reg cclk, rstb, tft_clk;
// Clocking counters
reg [31:0] px_count;
// Screen / Backlight variables
wire tft_backlight, tft_data_ena;
// Unused input variable for backlight
reg [7:0] switch;
// Boring variables that are 0 during reset and 1 otherwise
wire tft_display,tft_vdd;
// register counters and enables
reg [31:0] iter; 
reg prev_enable;
// iterator 

//tft signals
wire [9:0] tft_x;
wire [8:0] tft_y;
wire tft_new_frame;

tft_driver TFT(
	.cclk(cclk),
	.rstb(rstb),
	.tft_backlight(tft_backlight),
	.tft_clk(tft_clk),
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
		$dumpfile("test_tft_driver.vcd");
		$dumpvars(0, test_tft_driver);
		// Initialize Inputs
		cclk = 0;
		switch = 123;
		// Color flags
		color = 0;
		// Clocking inputs
		rstb = 1; 
		tft_clk = 0;
		// Clocking counters
		px_count = 0;
		// Unused input variable for backlight
		// reg 
		iter = 0;
		// Wait 100 ns for global reset to finish
		#100;
		// Reset the device
		rstb = 0;
		#100;
		rstb = 1;
		// Set the previous enable to 1
		prev_enable = 1;
		// Set loop counters to 0
		iter = 0;
		// Wait for global reset
		#100;
<<<<<<< HEAD
        for (iter = 0; iter < (288*525*10); iter = iter + 1) begin
			#10;
			cclk = ~cclk;
			if(iter % 10 == 0) begin
				tft_clk = ~tft_clk;
				$display("%b, %d", tft_clk, iter);
			end
			if(iter == 10) begin
				rstb = 0;
			end
			if(iter == 30) begin
				rstb = 1;
			end
        end
		$finish;
	end
endmodule

`default_nettype wire //disable default_nettype so non-user modules work properly
