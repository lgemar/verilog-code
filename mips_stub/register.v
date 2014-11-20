`timescale 1 ps / 1 ps
`default_nettype none

module register(
	input wire rst, clk, write_ena,
	input wire [4:0] address1, address2, address3,	// TODO: rename address3 to write_reg
	input wire [31:0] write_data,
	output reg [31:0] read_data1, read_data2
);

// reg [31:0] registers [0:31];
// reg [31:0] i;

/*
assign read_data1 = registers[address1];
assign read_data2 = registers[address2];

always @(posedge clk) begin
	if(~rst) begin
		for (i = 0; i < 31; i = i + 1) registers[i] <= 32'b0;
	end
	else begin
		if(write_ena) begin
			registers[address3] <= write_data;
		end
	end
end
endmodule
`default_nettype wire
*/

reg [31:0] zero, at, v0, v1, a0, a1, a2, a3, t0, t1, t2, t3, t4, t5, t6, t7;
reg [31:0] s0, s1, s2, s3, s4, s5, s6, s7, t8, t9, k0, k1;
reg [31:0] gp, sp, fp, ra;

`define ZERO 5'b0
`define AT 5'd1
`define V0 5'd2
`define V1 5'd3
`define A0 5'd4
`define A1 5'd5
`define A2 5'd6
`define A3 5'd7
`define T0 5'd8
`define T1 5'd9
`define T2 5'd10
`define T3 5'd11
`define T4 5'd12
`define T5 5'd13
`define T6 5'd14
`define T7 5'd15
`define S0 5'd16
`define S1 5'd17
`define S2 5'd18
`define S3 5'd19
`define S4 5'd20
`define S5 5'd21
`define S6 5'd22
`define S7 5'd23
`define T8 5'd24
`define T9 5'd25
`define K0 5'd26
`define K1 5'd27
`define GP 5'd28
`define SP 5'd29
`define FP 5'd30
`define RA 5'd31
always@(*) begin
	// Write to registers
	if(write_ena) begin
		case(address3) 
			`ZERO: zero <= 32'b0;
			`AT: at <= write_data;
			`V0: v0 <= write_data;
			`V1: v1 <= write_data;
			`A0: a0 <= write_data;
			`A1: a1 <= write_data;
			`A2: a2 <= write_data;
			`A3: a3 <= write_data;
			`T0: t0 <= write_data;
			`T1: t1 <= write_data;
			`T2: t2 <= write_data;
			`T3: t3 <= write_data;
			`T4: t4 <= write_data;
			`T5: t5 <= write_data;
			`T6: t6 <= write_data;
			`T7: t7 <= write_data;
			`S0: s0 <= write_data;
			`S1: s1 <= write_data;
			`S2: s2 <= write_data;
			`S3: s3 <= write_data;
			`S4: s4 <= write_data;
			`S5: s5 <= write_data;
			`S6: s6 <= write_data;
			`S7: s7 <= write_data;
			`T8: t8 <= write_data;
			`T9: t9 <= write_data;
			`K0: k0 <= write_data;
			`K1: k1 <= write_data;
			`GP: gp <= write_data;
			`SP: sp <= write_data;
			`FP: fp <= write_data;
			`RA: ra <= write_data;
		endcase
	end

	// Put correct output on read_data1
	case(address1)
		`ZERO: read_data1 <= 32'b0;
		`AT: at <= write_data;
		`V0: read_data1 <= v0;
		`V1: read_data1 <= v1;
		`A0: read_data1 <= a0;
		`A1: read_data1 <= a1;
		`A2: read_data1 <= a2;
		`A3: read_data1 <= a3;
		`T0: read_data1 <= t0;
		`T1: read_data1 <= t1;
		`T2: read_data1 <= t2;
		`T3: read_data1 <= t3;
		`T4: read_data1 <= t4;
		`T5: read_data1 <= t5;
		`T6: read_data1 <= t6;
		`T7: read_data1 <= t7;
		`S0: read_data1 <= s0;
		`S1: read_data1 <= s1;
		`S2: read_data1 <= s2;
		`S3: read_data1 <= s3;
		`S4: read_data1 <= s4;
		`S5: read_data1 <= s5;
		`S6: read_data1 <= s6;
		`S7: read_data1 <= s7;
		`T8: read_data1 <= t8;
		`T9: read_data1 <= t9;
		`K0: read_data1 <= k0;
		`K1: read_data1 <= k1;
		`GP: read_data1 <= gp;
		`SP: read_data1 <= sp;
		`FP: read_data1 <= fp;
		`RA: read_data1 <= ra;
	endcase

	// Put correct output on read_data2
	case(address2)
		`ZERO: read_data2 <= 32'b0;
		`AT: at <= at;
		`V0: read_data2 <= v0;
		`V1: read_data2 <= v1;
		`A0: read_data2 <= a0;
		`A1: read_data2 <= a1;
		`A2: read_data2 <= a2;
		`A3: read_data2 <= a3;
		`T0: read_data2 <= t0;
		`T1: read_data2 <= t1;
		`T2: read_data2 <= t2;
		`T3: read_data2 <= t3;
		`T4: read_data2 <= t4;
		`T5: read_data2 <= t5;
		`T6: read_data2 <= t6;
		`T7: read_data2 <= t7;
		`S0: read_data2 <= s0;
		`S1: read_data2 <= s1;
		`S2: read_data2 <= s2;
		`S3: read_data2 <= s3;
		`S4: read_data2 <= s4;
		`S5: read_data2 <= s5;
		`S6: read_data2 <= s6;
		`S7: read_data2 <= s7;
		`T8: read_data2 <= t8;
		`T9: read_data2 <= t9;
		`K0: read_data2 <= k0;
		`K1: read_data2 <= k1;
		`GP: read_data2 <= gp;
		`SP: read_data2 <= sp;
		`FP: read_data2 <= fp;
		`RA: read_data2 <= ra;
	endcase
end

always @(posedge clk) begin
	if(~rst) begin
		// Set the output registers to a known state
		read_data1 <= 32'b0;
		read_data2 <= 32'b0;

		// Set internal registers to a known state
		zero <= 32'b0;
		at <= 32'd0;
		v0 <= 32'd0;
		v1 <= 32'd0;
		a0 <= 32'd0;
		a1 <= 32'd0;
		a2 <= 32'd0;
		a3 <= 32'd0;
		t0 <= 32'd0;
		t1 <= 32'd0;
		t2 <= 32'd0;
		t3 <= 32'd0;
		t4 <= 32'd0;
		t5 <= 32'd0;
		t6 <= 32'd0;
		t7 <= 32'd0;
		s0 <= 32'd0;
		s1 <= 32'd0;
		s2 <= 32'd0;
		s3 <= 32'd0;
		s4 <= 32'd0;
		s5 <= 32'd0;
		s6 <= 32'd0;
		s7 <= 32'd0;
		t8 <= 32'd0;
		t9 <= 32'd0;
		k0 <= 32'd0;
		k1 <= 32'd0;
		gp <= 32'd0;
		sp <= 32'd0;
		fp <= 32'd0;
		ra <= 32'd0;
	end
end

endmodule
`default_nettype wire
