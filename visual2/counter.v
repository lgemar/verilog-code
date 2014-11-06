`timescale 1ns/1ps
`default_nettype none

module counter;

	input wire clk,
	input wire [7:0] data,
	input wire rstb,
	input wire en,
	output wire [7:0] out

	reg [7:0] count;

	assign out = count;

	always @(posedge clk) begin
		if (rstb)  
			count = 8'b0;
		else if (en)
			count = count + 1'b1; 
	end

endmodule
`default_nettype wire
