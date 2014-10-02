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

module alu_sll_4bit_test;

	// parameter width
	parameter N = 32;

	// testing variables
	reg [N:0] i;
	reg [N:0] j;

	// Inputs
	reg [N-1:0] A;
	reg [2:0] S;

	// Outputs
	wire [N-1:0] Z;

	// Instantiate the Unit Under Test (UUT)
	alu_sll_4bit #(.N(N)) uut (
		.A(A), 
		.S(S), 
		.Z(Z)
	);

	initial begin
		// Insert the dumps here
		$dumpfile("alu_sll_4bit_test.vcd");
		$dumpvars(0, alu_sll_4bit_test);

		// Initialize Inputs
		A = 32'h00000000;
		S = 5'b00000;

		// Wait 100 ns for global reset to finish
		#100;

		// Add stimulus here
		for (j = 0; j <= 8; j = j + 1) begin
			for (i = 0; i <= 8; i = i + 1) begin
				A = i;
				S = j;
				#100;
				$display("Input: %b; Shift: %d; Output: %b;", A, S, Z);
			end
		end

		$finish;
	end
endmodule

