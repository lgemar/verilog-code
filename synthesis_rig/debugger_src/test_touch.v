`timescale 1ns / 1ps

module test_touch;

	// Inputs
	reg cclk;
	reg rstb;
	wire touch_busy;
	wire data_in;

	// Outputs
	wire touch_clk;
	wire touch_csb;
	wire data_out;
	wire [8:0] x, y, z;

	// Instantiate the Unit Under Test (UUT)
	touchpad_controller uut (
		.cclk(cclk), 
		.rstb(rstb), 
		.touch_busy(touch_busy), 
		.data_in(data_in), 
		.touch_clk(touch_clk), 
		.touch_csb(touch_csb), 
		.data_out(data_out), 
		.x(x), 
		.y(y),
		.z(z)
	);
	
	//instantiate a model of the ad7873
	// change the NOISE parameter to 1 to simulate some noise on the conversion
	ad7873 #(.NOISE(1)) AD7873 (
		.dclk(touch_clk),
		.din(data_out),
		.csb(touch_csb),
		.dout(data_in),
		.busy(touch_busy)
	);
	
	//run our main clock
	always #5 cclk = ~cclk;

	initial begin
		// Initialize Inputs
		cclk = 0;
		rstb = 0;		
		//assert reset for long enough
		repeat(2) @(posedge cclk);
		rstb = 1;
	
		//let the simulation run
		repeat (100_000) @(posedge touch_clk); //you need to wait a looong time to properly test your averager
		$finish;
		
	end
endmodule

