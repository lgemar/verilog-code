`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_add_32bit 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_sub_32bit(A, B, S, OF);

	//port definitions
	input wire CI;
	input wire [31:0] A;
	input wire [31:0] B;
	output wire [31:0] S;
	output wire OF;
	wire REAL_CI;
	wire [31:0] B_INV;

	assign B_INV = ~B;
	assign REAL_CI = 1'b1;

	alu_add_32bit SUB (.A(A), .B(B_INV), .CI(REAL_CI), .S(S), .OF(OF));
endmodule
`default_nettype wire
