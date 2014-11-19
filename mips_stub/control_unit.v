`timescale 1ns/1ps
`default_nettype none

module control_unit(
	input wire cclk, rstb; // clock and reset pins
	input wire [31:0] Instr;

	// Multiplexer selects
	// TODO: change the wires width to the inputs that I'm sending. My logic
	// mips.v takes into account all instructions, I think.
	output reg MemtoReg, RegDst, IorD, PCSrc, ALUSrcA;
	output reg [1:0] ALUSrcB; 

	// TODO: do we need MemRead signal?
	// TODO: add outputs ALUSrcB[1:0] and PCWriteCond[1:0] - we'll discuss the
	// logic tonight for branch and jump
	// TODO: remove Branch, add ExtOp (depending on the type of itype
	// instructions, we need either sign extend or zero extend).
	output reg IRWrite, MemWrite, PCWrite, Branch, RegWrite;

	// TODO: Let's factor out decoder into a separate module, I'm calling the
	// decoder in mips to get the ALUControl. Send me back only ALUOp, don't
	// decode it here into ALUControl
	output wire [2:0] ALUControl;
);

	// Internal Vars
	// ALU communication
	output reg [1:0] ALUOp;
	// Opcodes and Funct codes
	wire [5:0] Opcode, Funct;
	assign Opcode = Instr[31:26];
	assign Funct = Instr[5:0];

	alu_decoder ALU_DECODER (
		.Funct(Funct), 
		.Opcode(ALUOp), 
		.ALUControl(ALUControl)
	);

	// Internal State Defines
	`define FETCH 4'd0
	`define DECODE 4'd1
	`define MEM_ADR 4'd2
	`define MEM_READ 4'd3
	`define MEM_WRITEBACK 4'd4
	`define MEM_WRITE 4'd5
	`define EXECUTE 4'd6
	`define ALU_WRITEBACK 4'd7
	`define BRANCH 4'd8
	`define ITYPE_EXECUTE 4'd9
	`define ITYPE_WRITEBACK 4'd10
	`define JUMP 4'd11

	// Instruction Opcode Defines: current operations supported by controller
	// R-type opcodes
	`define R_TYPE 6'd0
	// Memory opcodes
	`define SW 6'd34
	`define LW 6'd43
	// Branch opcodes
	`define BEQ 6'd4
	// Itype opcodes
	`define ADDI 6'd8
	// J-type opcodes
	`define J_TYPE 6'd2

	// Internal Vars
	reg [3:0] state;

	always @(posedge clk) begin
		if(~rstb) begin
			// State reset, same as fetch
			state <= `DECODE;
			// Multiplexer selects
			MemtoReg <= 1'b0; // x
			RegDst <= 1'b0; // x
			IorD <= 1'b0;
			PCSrc <= 2'b00;
			ALUSrcA <= 1'b0;
			ALUSrcB <= 2'b01;
			// Register Enables
			IRWrite <= 1'b1;
			MemWrite <= 1'b0; // x
			PCWrite <= 1'b1;
			Branch <= 1'b0; // x
			RegWrite <= 1'b0; // x
			// ALU Op
			ALUOp <= 2'b00;
		end 
		else begin
			case(state)
				`FETCH: begin
					// State update
					state <= `DECODE;
					// Multiplexer selects
					MemtoReg <= 1'b0; // x
					RegDst <= 1'b0; // x
					IorD <= 1'b0;
					PCSrc <= 2'b00; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b01;
					// Register Enables
					IRWrite <= 1'b1;
					MemWrite <= 1'b0; // x
					PCWrite <= 1'b1;
					Branch <= 1'b0; // x
					RegWrite <= 1'b0; // x
					// ALU Op
					ALUOp <= 2'b00;
				end
				`DECODE: begin
					case(Opcode)
						`LW, `SW: state <= `MEM_ADR;
						`R_TYPE: state <= `EXECUTE;
						`BEQ: state <= `BRANCH;
						`ADDI: state <= `ITYPE_EXECUTE;
						`J_TYPE: state <= `JUMP;
					endcase
					// Multiplexer selects
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b11;
					// Register Enables
					// ALU Op
					ALUOp <= 2'b00;
				end
				`MEM_ADR: begin
					case(Opcode)
						`LW: state <= `MEM_READ;
						`SW: state <= `MEM_WRITE;
					endcase
					// Multiplexer selects
					ALUSrcA <= 1'b1;
					ALUSrcB <= 2'b10;
					// Register Enables
					// ALU Op
					ALUOp <= 2'b00;
				end
				`MEM_READ: begin
					state <= `MEM_WRITEBACK;
					// Multiplexer selects
					IorD <= 1'b1;
					// Register Enables
					// ALU Op
				end
				`MEM_WRITEBACK: begin
					state <= `FETCH;
					// Multiplexer selects
					MemtoReg <= 1'b1;
					RegDst <= 1'b0;
					// Register Enables
					RegWrite <= 1'b1; // x
					// ALU Op
				end
				`MEM_WRITE: begin
					state <= `FETCH;
					// Multiplexer selects
					IorD <= 1'b0;
					// Register Enables
					MemWrite <= 1'b1; // x
					// ALU Op
				end
				`EXECUTE: begin
					state <= `ALU_WRITEBACK;
					// Multiplexer selects
					ALUSrcA <= 1'b1;
					ALUSrcB <= 2'b00;
					// Register Enables
					// ALU Op
					ALUOp <= 2'b10;
				end
				`ALU_WRITEBACK: begin
					state <= `FETCH;
					// Multiplexer selects
					MemtoReg <= 1'b0;
					RegDst <= 1'b1;
					// Register Enables
					// ALU Op
				end
				`BRANCH: begin
					state <= `FETCH;
					// Multiplexer selects
					PCSrc <= 2'b01;
					ALUSrcA <= 1'b1;
					ALUSrcB <= 2'b00;
					// Register Enables
					Branch <= 1'b1;
					// ALU Op
					ALUOp <= 2'b01;
				end
				`ITYPE_EXECUTE: begin
					state <= `ITYPE_WRITEBACK;
					// Multiplexer selects
					ALUSrcA <= 1'b1;
					ALUSrcB <= 2'b10;
					// Register Enables
					// ALU Op
					ALUOp <= 2'b00;
				end
				`ITYPE_WRITEBACK: begin
					state <= `FETCH;
					// Multiplexer selects
					MemtoReg <= 1'b0; // x
					RegDst <= 1'b1; // x
					// Register Enables
					RegWrite <= 1'b1; // x
					// ALU Op
				end
				`JUMP: begin
					state <= `FETCH;
					// Multiplexer selects
					PCSrc <= 2'b10;
					// Register Enables
					PCWrite <= 1'b1;
					// ALU Op
				end
			endcase
		end
	end
endmodule
`default_nettype wire