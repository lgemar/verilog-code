`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Design Name:   shift_in_test
////////////////////////////////////////////////////////////////////////////////

module shift_in_test;

	// parameter 
	parameter WIDTH = 32;
	parameter DATA_WIDTH = 12;

	// test module variables
	reg [WIDTH-1:0] i;
	// Inputs
	reg clk, data_in, ena, rst;

	// Outputs
	wire [DATA_WIDTH-1:0] data_out;

	// Instantiate the Unit Under Test (UUT)
	shift_in uut (
		.clk(clk), 
		.data_in(data_in), 
		.ena(ena),
		.rst(rst), 
		.data_out(data_out)
	);

	always #10 clk = ~clk;
	integer seed = 0;
	always @(posedge clk) begin
		data_in = $random(seed);
		i = i + 1;
	end
	always @(posedge clk) begin
		rst = (i % 40 != 0);
	end

	initial begin
		// Insert the dumps here
		$dumpfile("shift_in_test.vcd");
		$dumpvars(0, shift_in_test);

		// Initialize Inputs
		i = 0;
		clk = 0;
		data_in = 0;
		ena = 0;
		rst = 1;

		// Wait 100 ns for global reset to finish
		#100;

		// Reset the module
		#50;
		rst = 0;
		#50;
		rst = 1;
		ena = 1;
        
		repeat(1000) begin
			@(posedge clk);
		end
		
		$finish;
	end
endmodule

