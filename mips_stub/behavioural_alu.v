`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    behavioural_alu 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "alu_op_codes.v"
module behavioural_alu(X,Y,op_code, Z, zero, overflow, equal);

	//port definitions
	input  wire [31:0] X,Y;
	input  wire [3:0] op_code;
	output reg  [31:0] Z;
	output reg overflow;
	output wire zero, equal;
	
	assign zero = Z == 0;
	assign equal = X == Y;
	
	wire signed [31:0] X_s, Y_s, sra;
	assign X_s = X;
	assign Y_s = Y;
	
	assign sra = Y_s >>> X_s;
	
	
	always @(*) begin
		case(op_code)
			`OP_AND : Z = X & Y;
			`OP_OR  : Z = X | Y;
			`OP_XOR : Z = X ^ Y;
			`OP_NOR : Z = ~(X | Y);
			`OP_ADD : Z = X_s + Y_s;
			`OP_SUB : Z = X_s - Y_s;
			`OP_SLT : Z = {31'b0, (X_s < Y_s)};
			`OP_SRL : Z = Y >> X;
			`OP_SLL : Z = Y << X;
			`OP_SRA : Z = (|X[31:5]) ? 32'h0 : sra;
			default : Z = 0;
		endcase
	end
	
	reg signed [31:0] sum_diff;
	
	always @(*) begin
		case(op_code)
			`OP_ADD : begin
				sum_diff = X + Y;
				case ({X[31], Y[31]})
					2'b00 : overflow = sum_diff[31];
					2'b01 : overflow = 1'b0;
					2'b10 : overflow = 1'b0;
					2'b11 : overflow = ~sum_diff[31];
				endcase
			end
			`OP_SUB : begin
				sum_diff = X - Y;
				case ({X[31], Y[31]})
					2'b00 : overflow = 1'b0;
					2'b01 : overflow = sum_diff[31];
					2'b10 : overflow = ~sum_diff[31];
					2'b11 : overflow = 1'b0;
				endcase
			end
			default : begin
				overflow = 0;
			end
		endcase
	end
	
endmodule
`default_nettype wire
