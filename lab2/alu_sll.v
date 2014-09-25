`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_srl.v
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////

module alu_sll(A, Z);
	parameter WIDTH = 32;
	parameter SHIFT = 0;
 
	input wire [(WIDTH - 1):0] A;
	output wire [(WIDTH - 1):0] Z;
	
	reg [(WIDTH-1):0] TEMP = 32'h00000000;
	assign Z[(WIDTH-1)-SHIFT:0] = TEMP[(WIDTH-1)-SHIFT:0];
	assign Z[(WDITH-1):SHIFT] = A[(WIDTH-1)-SHIFT:0];
endmodule
