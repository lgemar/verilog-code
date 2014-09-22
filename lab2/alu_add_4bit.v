`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_add_4bit 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_add_4bit(A, B, CI, S, CO);

	//port definitions
	input wire CI;
	input wire [3:0] A, B;
	output wire [3:0] S;
	output wire CO;

	// extra useful wires
	wire carry_out_01, carry_in_23;

	// instantiate module's hardware
	assign carry_in_23 = carry_out_01;

	alu_add_2bit ADD_01 (.A(A[1:0]), .B(B[1:0]), .CI(CI), .S(S[1:0]), .CO(carry_out_01));
	alu_add_2bit ADD_23 (.A(A[3:2]), .B(B[3:2]), .CI(carry_in_23), .S(S[3:2]), .CO(CO));

endmodule
`default_nettype wire
