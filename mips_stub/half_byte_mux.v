`timescale 1ns / 1ps
`default_nettype none

module half_byte_mux(x, byte_select, y);
	input  wire [31:0] x;
	input  wire [2:0] byte_select;
	output reg  [3:0] y;
	
	always @(*) begin
		case(byte_select)
			3'd7  : y = x[ 3: 0];
			3'd6  : y = x[ 7: 4];
			3'd5  : y = x[11: 8];
			3'd4  : y = x[15:12];
			3'd3  : y = x[19:16];
			3'd2  : y = x[23:20];
			3'd1  : y = x[27:24];
			3'd0  : y = x[31:28];
			default: y = 4'd0;
		endcase
	end
endmodule

`default_nettype wire
