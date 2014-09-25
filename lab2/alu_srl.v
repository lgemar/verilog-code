`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_srl.v
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////

module alu_srl(A, Z);
	parameter WIDTH = 32;
	parameter SHIFT = 0;
 
	input wire [(WIDTH - 1):0] A;
	output wire [(WIDTH - 1):0] Z;
	wire [(SHIFT - 1):0] TEMP;
	
	assign TEMP = {SHIFT{1'b0}};
	assign Z[31:31-SHIFT] = TEMP[SHIFT:0];
	assign Z[31-SHIFT:0] = A[31:SHIFT];
endmodule
