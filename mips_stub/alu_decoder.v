`timescale 1ns/1ps
`default_nettype none
module alu_decoder(
	input wire [5:0] Funct;
	input wire [1:0] ALUOp;
	output reg [2:0] ALUControl;
);

	// Function Enumeration 
	`define FUNCT_ADD 6'b100000
	`define FUNCT_SUB 6'b100010
	`define FUNCT_AND 6'b100100
	`define FUNCT_OR 6'b100101
	`define FUNCT_SLT 6'b101010

	// Opcode enumeration 
	`define ALU_ADD 3'b010
	`define ALU_SUBTRACT 3'b110
	`define ALU_AND 3'b000
	`define ALU_OR 3'b001
	`define ALU_SLT 3'b111

	always @(*) begin
		if (ALUOp == 2'b00) begin
			ALUControl <= `ALU_ADD;
		end
		else if (ALUOp[0]) begin
			ALUControl <= `ALU_SUBTRACT;
		end
		else begin
			case(Funct)
				`FUNCT_ADD: ALUControl <= `ALU_ADD;
				`FUNCT_SUB: ALUControl <= `ALU_SUBTRACT;
				`FUNCT_AND: ALUControl <= `ALU_AND;
				`FUNCT_OR: ALUControl <= `ALU_OR;
				`FUNCT_SLT: ALUControl <= `ALU_SLT;
			endcase
		end
	end
endmodule
`default_nettype wire
