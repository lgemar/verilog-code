`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_srl_2bit
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_srl(A, S, Z);

    parameter N = 32;

	//port definitions

	input wire [(N-1):0] A;
	input wire [5:0] S;
    output wire [(N-1):0] Z;
    wire [(N-1):0] sr2, sr4, sr8, sr16, sr32;

	alu_sr_32bit #(.N(N)) MUX6 (.A(A), .S(S[5]), .Z(sr32));
	alu_sr_16bit #(.N(N)) MUX5 (.A(sr32), .S(S[4]), .Z(sr16));
	alu_sr_8bit #(.N(N)) MUX4 (.A(sr16), .S(S[3]), .Z(sr8));
	alu_sr_4bit #(.N(N)) MUX3 (.A(sr8), .S(S[2]), .Z(sr4));

	alu_sr_2bit #(.N(N)) MUX2 (.A(sr4), .S(S[1]), .Z(sr2));
	alu_sr_1bit #(.N(N)) MUX1 (.A(sr2), .S(S[0]), .Z(Z));
endmodule
`default_nettype wire
