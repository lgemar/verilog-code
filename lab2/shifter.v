`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    shifter
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module shifter(A, S, Z);

    parameter WIDTH = 2;
	parameter SHIFT = 1;

	//port definitions

	input wire [(N-1):0] A;
	input wire S;
    output wire [(N-1):0] Z;
    wire [(N-1):0] B;

    assign B[N-3:0] = A[N-1:2];
    assign B[N-1:N-2] = 2'b0;
    
	mux_2to1 #(.N(N)) MUX (.X(A), .Y(B), .S(S), .Z(Z));
endmodule
`default_nettype wire