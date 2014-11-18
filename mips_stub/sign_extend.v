`timescale 1ns / 1ps
`default_nettype none
module sign_extend(
	input wire [15:0] instr,
	output wire [31:0] SignImm
);
	assign SignImm [15:0] = instr;
	assign SignImm [31:16] = {16{instr[15]}};
endmodule
`default_nettype wire
