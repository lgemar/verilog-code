`timescale 1ns / 1ps
`default_nettype none

module alu_add_2bit_test;

	reg [1:0] A;
	reg [1:0] B;
	reg CI;
	wire [1:0] S;
	wire CO;
 
	alu_add_2bit uut( .A(A), .B(B), .CI(CI), .S(S), .CO(CO));

	initial begin
		// Initialize Inputs
		A = 2'b11;
		B = 2'b11;
		CI = 2'b00;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		A = 2'b11;
		B = 2'b11;
		CI = 2'b11;
		#100;

		A = 2'b00;
		B = 2'b00;
		CI = 2'b00;
		#100;

		A = 2'b01;
		B = 2'b10;
		CI = 2'b00;
		#100;

		A = 2'b11;
		B = 2'b10;
		CI = 2'b00;
		#100;

		$finish;
	end
endmodule

`default_nettype wire
