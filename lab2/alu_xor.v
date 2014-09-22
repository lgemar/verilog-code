`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_xor 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_xor(A, B, Z);
	// parameter definitions
	parameter N = 8;

	//port definitions
	input wire [N-1:0] A, B;
	output wire [N-1:0] Z;

	// instantiate module's hardware
	assign Z = A ^ B;
endmodule
`default_nettype wire
