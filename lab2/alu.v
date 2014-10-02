`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu(X, Y, Z, op_code, overflow, equal, zero);
	parameter N = 32;
	input wire [31:0] X;
	input wire [31:0] Y;
	input wire [3:0] op_code;
	output wire [31:0] Z;
	output wire overflow;
	output wire equal;
	output wire zero;
	
	// AND module
	wire [31:0] and_out;
	alu_and #(.WIDTH(N)) AND(.A(X), .B(Y), .Z(and_out));

	// OR module
	wire [31:0] or_out;
	alu_or #(.WIDTH(N)) OR(.A(X), .B(Y), .Z(or_out));

	// XOR module
	wire [31:0] xor_out;
	alu_xor #(.WIDTH(N)) XOR(.A(X), .B(Y), .Z(xor_out));

	// WIDTHOR module
	wire [31:0] nor_out;
	alu_nor #(.WIDTH(N)) NOR(.A(X), .B(Y), .Z(nor_out));

	// Addition module
	wire [31:0] add_out;
	wire add_overflow;
	alu_add_32bit ADD (.A(X), .B(Y), .CI(1'b0), .S(add_out), .OF(add_overflow));

	// Subtraction module
	wire [31:0] sub_out;
	wire sub_overflow;
	alu_sub_32bit SUB (.A(X), .B(Y), .S(sub_out), .OF(sub_overflow));

	// SLT module
	wire [31:0] slt_out;
	alu_slt SLT (.A(X), .B(Y), .Z(slt_out));

	// SLT2 module
	wire [31:0] slt_out2;
	alu_slt SLT2 (.A(Y), .B(X), .Z(slt_out2));

	// srl module
	wire [31:0] srl_out;
	alu_srl SRL (.A(X), .S(Y[4:0]), .Z(srl_out));

	// sll module
	wire [31:0] sll_out;
	alu_sll SLL (.A(X), .S(Y[4:0]), .Z(sll_out));

	// sra module
	wire [31:0] sra_out;
	alu_sra SRA (.A(X), .S(Y[4:0]), .Z(sra_out));
    
    wire reserved;
    alu_res RES (.S(op_code), .Z(reserved));

	mux_16to1 #(.WIDTH(N)) MUX (.A(and_out), 
				   .B(or_out), 
				   .C(xor_out), 
				   .D(nor_out), 
				   .E(32'b0), 
				   .F(add_out), 
				   .G(sub_out), 
				   .H(slt_out), 
				   .I(srl_out), 
				   .J(sll_out), 
				   .K(sra_out),
				   .L(32'b0), 
				   .M(32'b0), 
				   .N(32'b0), 
				   .O(32'b0),
				   .P(32'b0), 
				   .S(op_code), 
				   .Z(Z)
				);

	assign zero = ~(|Z[31:0]) & ~reserved;
	assign equal = &(~slt_out & ~slt_out2);
	assign overflow = &(~(op_code ^ 4'b0101)) & add_overflow | &(~(op_code ^ 4'b0110)) & sub_overflow;
endmodule
`default_nettype wire
