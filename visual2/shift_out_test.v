`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Design Name:   shift_out_test
////////////////////////////////////////////////////////////////////////////////

module shift_out_test;

	// parameter 
	parameter WIDTH = 8;
	parameter DATA_WIDTH = 8;

	// test module variables
	reg [DATA_WIDTH-1:0] i;
	// Module Vars
	reg clk, ena, rst;
	wire data_out;
	reg [DATA_WIDTH-1:0] data_in;

	// Instantiate the Unit Under Test (UUT)
	shift_out uut (
		.clk(clk), 
		.data_in(data_in), 
		.ena(ena),
		.rst(rst), 
		.data_out(data_out)
	);

	always #10 clk = ~clk;

	always @(posedge clk) begin
		rst = (i % 40 != 0);
		i = i + 1;
	end

	always @(negedge rst) begin
		data_in = data_in + 1;
	end

	initial begin
		// Insert the dumps here
		$dumpfile("shift_out_test.vcd");
		$dumpvars(0, shift_out_test);

		// Initialize Inputs
		i = 0;
		clk = 0;
		data_in = 8'b0;
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

