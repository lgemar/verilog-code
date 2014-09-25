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
	reg B = 1'b0;
	
	reg [31:0] TEMP = 32'h00000000;
	assign Z[(WIDTH-1):(WIDTH-1)-SHIFT] = TEMP[(WIDTH-1):(WIDTH-1)-SHIFT];
	assign Z[(WIDTH-1)-SHIFT:0] = A[(WIDTH-1):SHIFT];
endmodule
