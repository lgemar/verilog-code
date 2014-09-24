`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_add_32bit 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////

module alu_add_32bit(A, B, CI, S, OF);

	//port definitions
	input wire CI;
	input wire [31:0] A;
	input wire [31:0] B;
	output wire [31:0] S;
	output wire OF;
	wire CO;

	// extra useful wires
	wire carry_out_01, carry_in_23;

	// instantiate module's hardware
	assign carry_in_23 = carry_out_01;

	alu_add_16bit ADD_01 (.A(A[15:0]), .B(B[15:0]), .CI(CI), .S(S[15:0]), .CO(carry_out_01));
	alu_add_16bit ADD_23 (.A(A[31:16]), .B(B[31:16]), .CI(carry_in_23), .S(S[31:16]), .CO(CO));

	assign OF = ~S[31] & A[31] & B[31] | S[31] & ~A[31] & ~B[31];
endmodule
`default_nettype wire
