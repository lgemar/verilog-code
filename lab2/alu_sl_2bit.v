`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_sl_2bit
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_sl_2bit(A, S, Z);

    parameter N = 2;

	//port definitions

	input wire [(N-1):0] A;
	input wire S;
    output wire [(N-1):0] Z;
    wire [(N-1):0] B;

    assign B[1:0] = 2'b0;
    assign B[N-1:2] = A[N-3:0];
    
	mux_2to1 #(.N(N)) MUX (.X(A), .Y(B), .S(S), .Z(Z));
endmodule
`default_nettype wire
