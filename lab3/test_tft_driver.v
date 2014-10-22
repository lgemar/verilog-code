`timescale 1ns / 1ps

`default_nettype none //makes undeclared nets errors instead of automatic wires

module test_tft_driver;

reg [7:0] tft_red, tft_green, tft_blue
reg tft_backlight, tft_clk, tft_data_ena,
reg tft_display,tft_vdd,

//clocking signals
reg cclk, cclk_n, tft_clk_buf, tft_clk_buf_n, clocks_locked;

//tft signals
reg [9:0] tft_x;
reg [8:0] tft_y;
reg tft_new_frame;

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
		/** Variables that we need to specify in order to run the test: 
		 * Initializers: 
		 *	    cclk -> unused in the module so value can be anything
		 *	    rstb -> set from 1 to 0 to 1 right before test
		 * 	    frequency_division -> should be 255
		 * 	    duty cycle -> probably set this to to 126
		 * Active variables: 
		 * 	    tft_clk -> can run at any frequency
		 * for each color: 
		 * 	for 2 iterations: 
		 * 		while( ~new_frame ): 
		 * 			if( tft_clk % 10 == 0 )
		 * 				if(R)
		 * 					print R
		 *				elif(G)
		 * 					print G
		 * 				else
		 * 					print B
		 * 			if( prev_enable == tft_data_ena )
		 * 				print '\n'
		 */
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
