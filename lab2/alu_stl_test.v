`timescale 1ns / 1ps
`default_nettype none

module alu_slt_test;

	reg [31:0] A;
	reg [31:0] B;
	wire [31:0] Z;
 
	// Counters
	reg [31:0] i;
	reg [31:0] j;
	reg desired;

	alu_slt #(.WIDTH(32)) uut( .A(A), .B(B), .Z(Z));

	initial begin
		// Insert the dumps here
		$dumpfile("alu_slt_test.vcd");
		$dumpvars(0, alu_slt_test);

		// Initialize Inputs
		A = 32'h0000;
		B = 32'h0000;
		j = 32'h0000;
		i = 32'h0000;

		// Add stimulus
		for (i = 0; i < 2^32; i = i + 101) begin
			j = j + 100;
			// set A equal to i and B to j
			A = i;
			B = j;
			// Set desired equal to A < B
			desired = A < B;
			#100
			// Display the result
			$display("Desired: %d; Calculated: %b\n", desired, Z);
		end
	  end
endmodule

`default_nettype wire
