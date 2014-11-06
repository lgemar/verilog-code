`timescale 1ns/1ps
`default_nettype none

module counter (
	input wire clk,
	input wire touch_clk,
	input wire rstb,
	input wire en,
	output wire [31:0] out
);
	reg [31:0] count;
	reg previous_touch_clk;
	wire clk_edge;

	assign out = count;

	assign clk_edge = touch_clk & ~previous_touch_clk;	

	always @(posedge clk) begin
		if(rstb) begin
			count <= 31'b0;
		end
		else if (en & clk_edge) begin
			count <= count + 1'b1; 
		end
		previous_touch_clk <= touch_clk;
	end

endmodule
`default_nettype wire
