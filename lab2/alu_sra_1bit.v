`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_shift_1bit
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_sra_1bit(A, S, Z, sign);

    parameter N = 2;

	//port definitions

	input wire sign;
	input wire [(N-1):0] A;
	input wire S;
    output wire [(N-1):0] Z;
    wire [(N-1):0] B;

    assign B[(N-2):0] = A[N-1:1];
    assign B[(N-1)] = sign;
    
	mux_2to1 #(.N(N)) MUX (.X(A), .Y(B), .S(S), .Z(Z));
endmodule
`default_nettype wire
