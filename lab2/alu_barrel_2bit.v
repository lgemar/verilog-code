`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_barrel_2bit
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_barrel_2bit(A, S, Z);

    parameter N = 2;

	//port definitions

	input wire [(N-1):0] A;
	input wire S;
    output wire [(N-1):0] Z;
    wire [(N-1):0] shifted2;

	alu_shift_2bit #(.N(N)) MUX (.A(A), .S(S[1]), .Z(shifted2));
	alu_shift_1bit #(.N(N)) MUX (.A(shifted2), .S(S[0]), .Z(Z));
endmodule
`default_nettype wire
