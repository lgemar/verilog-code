`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_srl.v
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////

module alu_sll(A, Z);
    parameter N = 32;

	//port definitions

	input wire [(N-1):0] A;
	input wire [5:0]S;
    output wire [(N-1):0] Z;
    wire [(N-1):0] sl2, sl4, sl8, sl16, sl32;

	alu_sl_32bit #(.N(N)) MUX6 (.A(A), .S(S[5]), .Z(sl32));
	alu_sl_16bit #(.N(N)) MUX5 (.A(sl32), .S(S[4]), .Z(sl16));
	alu_sl_8bit #(.N(N)) MUX4 (.A(sl16), .S(S[3]), .Z(sl8));
	alu_sl_4bit #(.N(N)) MUX3 (.A(sl8), .S(S[2]), .Z(sl4));

	alu_sl_2bit #(.N(N)) MUX2 (.A(sl4), .S(S[1]), .Z(sl2));
	alu_sl_1bit #(.N(N)) MUX1 (.A(sl2), .S(S[0]), .Z(Z));
endmodule
