`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_add_4bit 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_add_16bit(A, B, CI, S, CO);

	//port definitions
	input wire CI;
	input wire [15:0] A, B;
	output wire [15:0] S;
	output wire CO;

	// extra useful wires
	wire temp_out_in; 

	alu_add_4bit ADD_03 (.A(A[3:0]), .B(B[3:0]), .CI(CI), .S(S[3:0]), .CO(temp_out_in));
	alu_add_4bit ADD_47 (.A(A[4:7]), .B(B[4:7]), .CI(temp_out_in), .S(S[4:7]), .CO(temp_out_in));
	alu_add_4bit ADD_811 (.A(A[8:11]), .B(B[8:11]), .CI(temp_out_in), .S(S[8:11]), .CO(temp_out_in));
	alu_add_4bit ADD_1215 (.A(A[12:15]), .B(B[12:15]), .CI(temp_out_in), .S(S[12:15]), .CO(CO));

endmodule
`default_nettype wire
