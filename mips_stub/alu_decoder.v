`timescale 1ns/1ps
`default_nettype none
module alu_decoder(
	input wire [5:0] Funct,
	input wire [1:0] ALUOp,
	output reg [3:0] ALUControl
);

	// Function Enumeration 
	`define FUNCT_ADD 6'd32
	`define FUNCT_SUB 6'd34
	`define FUNCT_AND 6'd36
	`define FUNCT_OR 6'd37
	`define FUNCT_XOR 6'd38
	`define FUNCT_NOR 6'd39
	`define FUNCT_SLT 6'd42
	`define FUNCT_SLL 6'd0
	`define FUNCT_SRL 6'd2
	`define FUNCT_SRA 6'd3
	`define FUNCT_JR 6'd8
	
	// Opcode enumeration 
	`define ALU_AND 4'b0000
	`define ALU_OR  4'b0001
	`define ALU_XOR 4'b0010
	`define ALU_NOR 4'b0011
	`define ALU_ADD 4'b0101
	`define ALU_SUB 4'b0110
	`define ALU_SLT 4'b0111
	`define ALU_SRL 4'b1000
	`define ALU_SLL 4'b1001
	`define ALU_SRA 4'b1010

	always @(*) begin
		if (ALUOp == 2'b00) begin
			ALUControl <= `ALU_ADD;
		end
		else if (ALUOp[0]) begin
			ALUControl <= `ALU_SUB;
		end
		else begin
			case(Funct)
				`FUNCT_ADD: ALUControl <= `ALU_ADD;
				`FUNCT_SUB: ALUControl <= `ALU_SUB;
				`FUNCT_AND: ALUControl <= `ALU_AND;
				`FUNCT_OR : ALUControl <= `ALU_OR;
				`FUNCT_SLT: ALUControl <= `ALU_SLT;
				`FUNCT_XOR: ALUControl <= `ALU_XOR;
				`FUNCT_NOR: ALUControl <= `ALU_NOR;
				`FUNCT_SLL: ALUControl <= `ALU_SLL;
				`FUNCT_SRL: ALUControl <= `ALU_SRL;
				`FUNCT_SRA: ALUControl <= `ALU_SRA;
			endcase
		end
	end
endmodule
`default_nettype wire
