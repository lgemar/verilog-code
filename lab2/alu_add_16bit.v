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
	wire temp_out1, temp_out2, temp_out3; 

	alu_add_4bit ADD_03 (.A(A[3:0]), .B(B[3:0]), .CI(CI), .S(S[3:0]), .CO(temp_out1));
	alu_add_4bit ADD_47 (.A(A[7:4]), .B(B[7:4]), .CI(temp_out1), .S(S[7:4]), .CO(temp_out2));
	alu_add_4bit ADD_811 (.A(A[11:8]), .B(B[11:8]), .CI(temp_out2), .S(S[11:8]), .CO(temp_out3));
	alu_add_4bit ADD_1215 (.A(A[15:12]), .B(B[15:12]), .CI(temp_out3), .S(S[15:12]), .CO(CO));

endmodule
`default_nettype wire
