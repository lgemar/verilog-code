`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_and 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_add_1bit(A, B, CI, S, CO);
	//port definitions
	input wire A, B, CI;
	output wire S, CO; 

	// instantiate module's hardware
	assign S = (A & ~B & ~CI) | (~A & B & ~CI) | (~A & ~B & CI) | (A & B & CI);
	assign CO = (B & CI) | (A & CI) | (A & B);
endmodule
`default_nettype wire
