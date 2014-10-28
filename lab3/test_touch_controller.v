`timescale 1ns / 1ps

`default_nettype none //makes undeclared nets errors instead of automatic wires

module test_touch_controller;

    reg cclk, rstb, touch_clk, touch_busy, touch_data_in, touch_data_out, touch_csb;
    //touchpad signals
    wire [11:0] touch_x, touch_y, touch_z;

    wire reset;
    assign reset = ~rstb;

    touchpad_controller TFT(
        .cclk(cclk), 
        .rstb(rstb), 
        .touch_clk(touch_clk),
        .touch_busy(touch_busy),
        .data_in(touch_data_out),
        .data_out(touch_data_in),
        .touch_csb(touch_csb),
        .x(touch_x),
        .y(touch_y),
        .z(touch_z)
    );


	initial begin 
        // Insert the dumps here
        $dumpfile("test_touch_controller.vcd");
        $dumpvars(0, test_touch_controller);

        @always #5 cclk = ~cclk;
        @always touch_data_out = $random();

        
		// Initialize Inputs
        
		$finish;
	end
endmodule

`default_nettype wire //disable default_nettype so non-user modules work properly
