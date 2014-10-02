`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_sll_4bit
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////

module alu_sll_4bit(A, S, Z);
    parameter N = 32;

	//port definitions

	input wire [(N-1):0] A;
	input wire [2:0] S;
    output wire [(N-1):0] Z;
    wire [(N-1):0] sl2, sl4, sl8, sl16;

	alu_sl_4bit #(.N(N)) MUX3 (.A(A), .S(S[2]), .Z(sl4));

	alu_sl_2bit #(.N(N)) MUX2 (.A(sl4), .S(S[1]), .Z(sl2));
	alu_sl_1bit #(.N(N)) MUX1 (.A(sl2), .S(S[0]), .Z(Z));
endmodule
