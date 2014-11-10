`timescale 1 ps / 1 ps
`default_nettype none

module register(
	input wire rst, clk, write_ena,
	input wire [4:0] address1, address2, address3,
	input wire [31:0] write_data,
	output reg [31:0] read_data1, read_data2
);

reg [31:0] zero, at, v0, v1, a0, a1, a2, a3, t0, t1, t2, t3, t4, t5, t6, t7;
reg [31:0] s0, s1, s2, s3, s4, s5, s6, s7, t8, t9, k0, k1;
reg [31:0] gp, sp, fp, ra;

`define ZERO 5'b0
always @(posedge clk) begin
	if(~rst) begin
		// Set the output registers to a known state
		read_data1 <= 32'b0;
		read_data2 <= 32'b0;

		// Set internal registers to a known state

	end
	else begin

		// Write to registers
		if(write_ena) begin
			case(address3) 
				`ZERO: zero <= 32'b0;
			endcase
		end

		// Put correct output on read_data1
		case(address1)
			`ZERO: read_data1 <= 32'b0;
		endcase

		// Put correct output on read_data2
		case(address2)
			`ZERO: read_data2 <= 32'b0;
		endcase
	end
end
endmodule
`default_nettype wire
