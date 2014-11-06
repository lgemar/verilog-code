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

	always @(posedge clk) begin
		if (rstb) begin 
			count = 0;
		end 
		else if (en) begin
			count = count + 1'b1; 
		end
	end

endmodule
`default_nettype wire
