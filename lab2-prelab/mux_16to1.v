`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    mux_16to1 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module mux_16to1(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, S, Z);
	// parameter definitions
	parameter WIDTH = 4;

	//port definitions
	input wire [(WIDTH - 1):0] A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P;
	input wire [3:0] S;
	output wire [(WIDTH - 1):0] Z;

	// instantiate module's hardware
	wire [(WIDTH - 1):0] mux_0_out, mux_1_out, mux_2_out, mux_3_out; 

	mux_4to1 #(.WIDTH(WIDTH)) MUX_0 (.A(A), .B(B), .C(C), .D(D), .S(S[1:0]), .Z(mux_0_out));
	mux_4to1 #(.WIDTH(WIDTH)) MUX_1 (.A(E), .B(F), .C(G), .D(H), .S(S[1:0]), .Z(mux_1_out));
	mux_4to1 #(.WIDTH(WIDTH)) MUX_2 (.A(I), .B(K), .C(L), .D(M), .S(S[1:0]), .Z(mux_2_out));
	mux_4to1 #(.WIDTH(WIDTH)) MUX_3 (.A(M), .B(N), .C(O), .D(P), .S(S[1:0]), .Z(mux_3_out));
	mux_4to1 #(.WIDTH(WIDTH)) MUX_4 (.A(mux_0_out), .B(mux_1_out), .C(mux_2_out), .D(mux_3_out), .S(S[3:2]), .Z(Z));
endmodule
`default_nettype wire
