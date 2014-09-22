`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_add_2bit 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_add_2bit(A, B, CI, S, CO);

	//port definitions
	input wire CI;
	input wire [1:0] A, B;
	output wire [1:0] S;
	output wire CO;

	// extra useful wires
	wire carry_out_0, carry_in_1;

	// instantiate module's hardware
	assign carry_in_1 = carry_out_0;

	alu_add_1bit ADD_0 (.A(A[0]), .B(B[0]), .CI(CI), .S(S[0]), .CO(carry_out_0));
	alu_add_1bit ADD_1 (.A(A[1]), .B(B[1]), .CI(carry_in_1), .S(S[1]), .CO(CO));
endmodule
`default_nettype wire
