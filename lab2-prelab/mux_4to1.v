`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    mux_4to1 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module mux_4to1(A, B, C, D, S, Z);
	// parameter definitions
	parameter WIDTH = 8;
	
	//port definitions
	input wire [(WIDTH - 1):0] A, B, C, D;
	input wire [1:0] S;
	output wire [(WIDTH-1):0] Z;

	// instantiate module's hardware
	wire [(WIDTH - 1):0] mux_0_out, mux_1_out;

	mux_2to1 #(.N(WIDTH)) MUX_0 (.X(A), .Y(B), .S(S[0]), .Z(mux_0_out));
	mux_2to1 #(.N(WIDTH)) MUX_1 (.X(C), .Y(D), .S(S[0]), .Z(mux_1_out));
	mux_2to1 #(.N(WIDTH)) MUX_2 (.X(mux_0_out), .Y(mux_1_out), .S(S[1]), .Z(Z));

endmodule
`default_nettype wire
