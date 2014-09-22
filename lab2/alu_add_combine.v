`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_add_combine 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_add_combine(A, B, CI, S, CO);

	// Size (in bits) of adders to be combined
	parameter IN = 1; // default of 1 bit
	parameter OUT = 2; // default of 2 bits

	//port definitions
	input wire CI;
	input wire [IN-1:0] A, B;
	output wire [IN-1:0] S;
	output wire CO;

	// extra useful wires
	wire carry_out_0;

	alu_add_2bit ADD_0 (.A(A[1:0]), .B(B[1:0]), .CI(CI), .S(S[1:0]), .CO(carry_out_0));
	alu_add_2bit ADD_1 (.A(A[3:2]), .B(B[3:2]), .CI(carry_out_0), .S(S[3:2]), .CO(CO));

endmodule
`default_nettype wire
