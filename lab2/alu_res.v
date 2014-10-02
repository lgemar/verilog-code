`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_res(S, Z);
	input wire [3:0] S;
    wire [5:0] ACC;
    output wire Z;

	alu_eq RES4 (.S(S), .V(4'b0100), .Z(ACC[0]));
	alu_eq RES11(.S(S), .V(4'b1011), .Z(ACC[1]));
	alu_eq RES12(.S(S), .V(4'b1100), .Z(ACC[2]));
	alu_eq RES13(.S(S), .V(4'b1101), .Z(ACC[3]));
	alu_eq RES14(.S(S), .V(4'b1110), .Z(ACC[4]));
	alu_eq RES15(.S(S), .V(4'b1111), .Z(ACC[5]));

    assign Z = |ACC[5:0];
endmodule
`default_nettype wire
