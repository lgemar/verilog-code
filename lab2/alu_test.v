`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_add_32bit 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////

module alu_test;

	reg signed [31:0] A;
	reg signed [31:0] B;
	reg [3:0] S;
	wire signed [31:0] Z;
	wire OF;
	wire EQUAL;
	wire ZERO;

	// testbench variables
	reg signed [31:0] i;
	reg signed [31:0] j;
 
	alu uut( .X(A), .Y(B), .S(S), .Z(Z), .OF(OF), .EQUAL(EQUAL), .ZERO(ZERO));

	initial begin
		// Insert the dumps here
		$dumpfile("alu_test.vcd");
		$dumpvars(0, alu_test);

		// Initialize Inputs
		A = 32'b0;
		B = 32'b0;
		j = 32'b0;
		i = 32'b0;
		S = 4'b0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		for (S = 0; S < 4'hf; S = S + 1) begin
			for (i = -128; i < 127; i = i + 32) begin
				j = j + 16;
				#100; // wait for j to increment
				// set A equal to i and B to j
				A = i;
				B = j;
				#100; // delay required after assignment
				// Display the results
				$display("Select: %d; X: %d; Y: %d", S, A, B);
				$display("Output: %d; Overflow: %d; EQUAL: %d; ZERO: %d", Z, OF, EQUAL, ZERO);
				$display("\n");
			end
		end
		$finish;
	end
endmodule

`default_nettype wire
