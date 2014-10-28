`timescale 1ns / 1ps

`default_nettype none //makes undeclared nets errors instead of automatic wires

module test_touch_controller;

    reg cclk, rstb, touch_clk, touch_busy, touch_data_in, touch_data_out, touch_csb;
    //touchpad signals
    wire [11:0] touch_x, touch_y, touch_z;

    touchpad_controller TFT(
        .cclk(cclk), 
        .rstb(rstb), 
        .touch_busy(touch_busy),
        .data_in(touch_data_out),

        .touch_clk(touch_clk),
        .data_out(touch_data_in),
        .touch_csb(touch_csb),
        .x(touch_x),
        .y(touch_y),
        .z(touch_z)
    );

    always @(*) begin
        reset = 0;
        cclk = 0; 
        touch_busy = 0;
        touch_data_out = 0;
    end

	initial begin 
		// Insert the dumps here
		$dumpfile("test_touch_controller.vcd");
		$dumpvars(0, test_touch_controller);

		reg data_in;
		reg touch_clk;

		always @(posedge touch_clk) begin
			data_in = $random();
		end		
		repeat(10000) begin
			cclk = ~cclk;
			#5;
		end

		$finish;
	end
endmodule

`default_nettype wire //disable default_nettype so non-user modules work properly
