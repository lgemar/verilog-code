`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_sra.v
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////

module alu_sra(A, Z);
	parameter WIDTH = 32;
	parameter SHIFT = 0;
 
	input wire [(WIDTH - 1):0] A;
	output wire [(WIDTH - 1):0] Z;
	
	reg [31:0] TEMP = 32'hffffffff;

	assign Z[(WIDTH-1):(WIDTH-1)-SHIFT] = TEMP[(WIDTH-1):(WIDTH-1)-SHIFT];

	assign Z[31-SHIFT:0] = A[31:SHIFT];
endmodule
