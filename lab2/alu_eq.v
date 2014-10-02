`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_eq(S, V, Z);
	input wire [3:0] S;
	input wire [3:0] V;
	output wire Z;
    wire [3:0] TEMP;
    
    assign TEMP = S ^ V;
    assign Z = ~(|TEMP[3:0]);
endmodule
`default_nettype wire
