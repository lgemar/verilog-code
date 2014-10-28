`timescale 1ns / 1ps

`default_nettype none //makes undeclared nets errors instead of automatic wires

module test_touch_controller;

touchpad_controller TFT(
);
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
