`timescale 1ns / 1ps
`default_nettype none

module alu_add_1bit_test;

	reg A;
	reg B;
	reg CI;
	wire S;
	wire CO;
 
	alu_add_1bit uut( .A(A), .B(B), .CI(CI), .S(S), .CO(CO));

	initial begin
		// Initialize Inputs
		A = 1'b1;
		B = 1'b1;
		CI = 1'b0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		A = 1'b1;
		B = 1'b1;
		CI = 1'b1;
		#100;

		$finish;
	end
endmodule

`default_nettype wire
