`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_shift_32bit
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_sra_32bit(A, S, Z);

    	parameter N = 2;

	//port definitions

	input wire [(N-1):0] A;
	input wire S;
    	output wire [(N-1):0] Z;
    	wire [(N-1):0] B;

    	assign B[N-1:0] = 32'hffffffff;
    
	mux_2to1 #(.N(N)) MUX (.X(A), .Y(B), .S(S), .Z(Z));
endmodule
`default_nettype wire
