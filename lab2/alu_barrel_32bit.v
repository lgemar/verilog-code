`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_barrel_2bit
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_barrel_32bit(A, S, Z);

    parameter N = 32;

	//port definitions

	input wire [(N-1):0] A;
	input wire [5:0]S;
    output wire [(N-1):0] Z;
    wire [(N-1):0] shifted2;

	alu_shift_16bit #(.N(N)) MUX5 (.A(A), .S(S[4]), .Z(shifted2));
	alu_shift_8bit #(.N(N)) MUX4 (.A(A), .S(S[3]), .Z(shifted2));
	alu_shift_4bit #(.N(N)) MUX3 (.A(A), .S(S[2]), .Z(shifted2));

	alu_shift_2bit #(.N(N)) MUX2 (.A(A), .S(S[1]), .Z(shifted2));
	alu_shift_1bit #(.N(N)) MUX1 (.A(shifted2), .S(S[0]), .Z(Z));
endmodule
`default_nettype wire
