`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:08:19 09/18/2014
// Design Name:   mux_4to1
// Module Name:   C:/Documents and Settings/student/My Documents/final_project/Lab2-prelab/mux_4to1_test.v
// Project Name:  Lab2-prelab
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mux_4to1
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mux_4to1_test;

	// testing variables
	reg [1:0] i;
	// parameter
	parameter WIDTH = 2;
	// Inputs
	reg [1:0] A;
	reg [1:0] B;
	reg [1:0] C;
	reg [1:0] D;
	reg [1:0] S;

	// Outputs
	wire [1:0] Z;

	// Instantiate the Unit Under Test (UUT)
	mux_4to1 #(.WIDTH(WIDTH)) uut (
		.A(A), 
		.B(B), 
		.C(C), 
		.D(D), 
		.S(S), 
		.Z(Z)
	);

	initial begin
		// Initialize Inputs
		i = 0;
		A = 2'b00;
		B = 2'b01;
		C = 2'b10;
		D = 2'b11;
		S = 0;

		// Wait 100 ns for global reset to finish
       		#100;

		// Add stimulus here
		for (i = 0; i < 4; i = i + 1) begin
			S = i;
			#100;
		end
		$finish;
	end
endmodule

