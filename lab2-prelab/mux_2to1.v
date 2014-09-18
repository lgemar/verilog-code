`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    mux_2to1 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module mux_2to1(X, Y, S, Z);
	// parameter definitions
	parameter N = 8;

	//port definitions
	input wire [(N-1):0] X, Y;
	input wire S;

	output wire [(N-1):0] Z;

	//module body
	assign Z = S ? Y : X;
endmodule
`default_nettype wire
