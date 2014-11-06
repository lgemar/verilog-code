`timescale 1ns/1ps
`default_nettype none

module counter (
	input wire clk,
	input wire rstb,
	input wire en,
	output wire [31:0] out
);
	reg [31:0] count;

	assign out = count;

	always @(posedge rstb) begin
		count = 31'b0;
	end
	always @(posedge clk) begin
		if (en & ~rstb) begin
			count = count + 1'b1; 
		end
	end

endmodule
`default_nettype wire
