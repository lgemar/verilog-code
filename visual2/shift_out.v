`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    shift_out 
//
//////////////////////////////////////////////////////////////////////////////////
/** Shifts data in from most significant to least significant bits 
  * @pre positive edge triggered
  * @post Once 12 clk cycles have passed, the data is locked in the output
  * 	until the rst goes low. 
  */
module shift_out(clk, data_in, ena, rst, data_out);
	input wire clk, ena, rst;
	input wire [7:0] data_in;
	output wire data_out;
	reg [7:0] mask;

	// Local vars
	wire current_data;
	wire [7:0] masked_data;

	assign masked_data = mask & data_in;
	assign data_out = |(masked_data) & rst;

	always @(negedge clk, negedge rst) begin
		if(~rst) begin
			mask <= 8'b0000_0001;
		end
		else if(ena & rst) begin
			mask <= (mask << 1);
		end
	end
endmodule
`default_nettype wire
