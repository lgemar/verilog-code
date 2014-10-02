`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_sr_16bit
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_sra_16bit(A, S, Z, sign);

    	parameter N = 2;

	//port definitions

	input wire sign;
	input wire [(N-1):0] A;
	input wire S;
    	output wire [(N-1):0] Z;
    	wire [(N-1):0] B;

    	assign B[N-17:0] = A[N-1:16];
    	assign B[N-1:N-16] = {16{sign}};
    
	mux_2to1 #(.N(N)) MUX (.X(A), .Y(B), .S(S), .Z(Z));
endmodule
`default_nettype wire
