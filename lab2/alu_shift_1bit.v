`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_shift_1bit
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_shift_1bit(A, S, Z);

    parameter N = 1;

	//port definitions
	input wire A, S, Z;
    wire B;

    assign B = ~A;
    
	mux_2to1 #(.N(N)) MUX (.X(A), .Y(B), .S(S), .Z(Z));
endmodule
`default_nettype wire
