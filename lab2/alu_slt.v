`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_slt.v
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////

module alu_slt(A, B, Z);

	parameter WIDTH = 32;

	//port definitions
	input wire [(WIDTH - 1):0] A, B;
	output wire [(WIDTH - 1):0] Z;

	// logical less than
	wire lt;

	// Wires to compute the subtraction
	wire [(WIDTH - 1):0] AminusB;
	wire OF;
	alu_sub_32bit SUB (.A(A), .B(B), .S(AminusB), .OF(OF));

	assign lt = ~A[31] & ~B[31] & AminusB[31] | A[31] & ~B[31] | A[31] & B[31] & AminusB[31];
	assign Z = {32{lt}};
endmodule
