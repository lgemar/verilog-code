`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_shift_1bit
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_shift_1bit(A, S, Z);

    parameter N = 2;

	//port definitions

	input wire [(N-1):0] A, S;
    output [(N-1):0] Z;
    wire [(N-1):0] B;

    assign B[(N-2):0] = A[N:1];
    assign B[(N-1):(N-2)] = 1'b0;
    
	mux_2to1 #(.N(N)) MUX (.X(A), .Y(B), .S(S), .Z(Z));
endmodule
`default_nettype wire
