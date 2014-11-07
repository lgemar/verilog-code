`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    shift_in 
//
//////////////////////////////////////////////////////////////////////////////////
/** Shifts data in from most significant to least significant bits 
  * @pre positive edge triggered
  * @post Once 12 clk cycles have passed, the data is locked in the output
  * 	until the rst goes low. 
  */
module shift_in(clk, touch_clk, data_in, ena, rst, data_out);
	input wire clk, touch_clk, data_in, ena, rst;
	output reg [11:0] data_out;
	reg [11:0] mask;

	reg previous_touch_clk;
	wire clk_edge;
	assign clk_edge = touch_clk & ~previous_touch_clk;	

	always @(posedge clk) begin
		if(~rst) begin
			data_out <= 12'b0;
			mask <= 12'b1000_0000_0000;
		end
		else if(ena & clk_edge) begin
			if(data_in) begin
				data_out <= data_out | mask;
			end
			mask <= (mask >> 1);
		end
		previous_touch_clk <= touch_clk;
	end
endmodule
`default_nettype wire
