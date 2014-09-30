
`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:08:19 09/18/2014
// Design Name:   alu_shift_1bit
// Module Name:   C:/Documents and Settings/student/My Documents/final_project/Lab2-prelab/alu_shift_1bit_test.v
// Project Name:  Lab2-prelab
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: alu_shift_1bit
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module alu_shift_1bit_test;

	// testing variables
	reg [1:0] i;

	// Inputs
	reg A;
	reg S;

	// Outputs
	wire Z;

	// Instantiate the Unit Under Test (UUT)
	alu_shift_1bit uut (
		.A(A), 
		.S(S), 
		.Z(Z)
	);

	initial begin
		// Insert the dumps here
		$dumpfile("alu_shift_1bit_test.vcd");
		$dumpvars(0, alu_shift_1bit_test);

		// Initialize Inputs
		i = 0;
		A = 1'b0;
		S = 1'b0;

		// Wait 100 ns for global reset to finish
		#100;

		// Add stimulus here
		for (i = 0; i < 2; i = i + 1) begin
			S = i;
			#100;
			$display("Input: %b; Shift: %b; Output: %b;", A, S, Z);
		end
		$finish;
	end
endmodule

