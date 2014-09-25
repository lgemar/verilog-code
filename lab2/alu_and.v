`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_and 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_and(A, B, Z);
	// parameter definitions
	parameter WIDTH = 8;

	//port definitions
	input wire [WIDTH-1:0] A, B;
	output wire [WIDTH-1:0] Z;

	// instantiate module's hardware
	assign Z = A & B;
endmodule
`default_nettype wire
