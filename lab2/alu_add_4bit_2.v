`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_add_4bit_2 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_add_4bit_2(A, B, CI, S, CO);

	//port definitions
	input wire CI;
	input wire [3:0] A, B;
	output wire [3:0] S;
	output wire CO;

	// extra useful wires
	wire [3:0] g; // generate wires
	wire [3:0] p; // propogate wires
	wire [4:0] c; // carry wires

	// instantiate module's hardware
	// assign carry in and carry out
	assign c[0] = CI;
	assign CO = c[4];

	// calculate generate and propogate signals
	assign g = A & B;
	assign p = A ^ B;

	// calculate c
	assign c[1] = g[0] | p[0] & c[0];
	assign c[2] = g[1] | p[1] & g[0] | &p[1:0] & c[0];
	assign c[3] = g[2] | p[2] & g[1] | &p[2:1] & g[0] | &p[2:0] & c[0];
	assign c[4] = g[3] | p[3] & g[2] | &p[3:2] & g[1] | &p[3:1] & g[0] | & p[3:0] & c[0];

	// calculate outputs
	assign S = p ^ c[3:0];
endmodule
`default_nettype wire
