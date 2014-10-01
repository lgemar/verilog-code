`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_sra.v
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////

module alu_sra(A, S, Z);
    parameter N = 32;

	//port definitions

	input wire [(N-1):0] A;
	input wire [5:0]S;
    output wire [(N-1):0] Z;
    wire [(N-1):0] shifted2, shifted4, shifted8, shifted16, shifted32;

	alu_sra_32bit #(.N(N)) MUX6 (.A(A), .S(S[5]), .Z(shifted32));
	alu_sra_16bit #(.N(N)) MUX5 (.A(shifted32), .S(S[4]), .Z(shifted16));
	alu_sra_8bit #(.N(N)) MUX4 (.A(shifted16), .S(S[3]), .Z(shifted8));
	alu_sra_4bit #(.N(N)) MUX3 (.A(shifted8), .S(S[2]), .Z(shifted4));

	alu_sra_2bit #(.N(N)) MUX2 (.A(shifted4), .S(S[1]), .Z(shifted2));
	alu_sra_1bit #(.N(N)) MUX1 (.A(shifted2), .S(S[0]), .Z(Z));
endmodule
