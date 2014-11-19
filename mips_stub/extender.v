`timescale 1ns/1ps

`default_nettype none

module extender(in, zero, out);

	input wire[15:0] in;
	input wire zero;
	output wire[31:0] out;

	assign out = zero ? {16'b0, in} : { {16{in[15]}}, in};
endmodule

`default_nettype wire
