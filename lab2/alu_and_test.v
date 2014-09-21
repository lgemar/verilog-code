`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:44:43 09/18/2014
// Design Name:   alu_and_test
// Module Name:   C:/Documents and Settings/student/My Documents/final_project/Lab2-prelab/alu_and_test_test.v
// Project Name:  Lab2-prelab
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: alu_and_test
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module alu_and_test;

	// parameter 
	parameter WIDTH = 32;
	// test module variables
	reg [WIDTH-1:0] i;
	// Inputs
	reg [WIDTH-1:0] A;
	reg [WIDTH-1:0] B;

	// Outputs
	wire [WIDTH-1:0] Z;

	// Instantiate the Unit Under Test (UUT)
	alu_and #(.N(WIDTH)) uut (
		.A(A), 
		.B(B), 
		.Z(Z)
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

