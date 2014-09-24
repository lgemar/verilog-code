`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    alu_add_32bit 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////

module alu_add_32bit_test;

	reg signed [31:0] A;
	reg signed [31:0] B;
	reg CI;
	wire signed [31:0] S;
	wire OF;

	// testbench variables
	reg signed [31:0] i;
	reg signed [31:0] j;
	reg signed [32:0] desired_sum;
	wire [31:0] desired_output;
	wire desired_carry_out;
 
	alu_add_32bit uut( .A(A), .B(B), .CI(CI), .S(S), .OF(OF));

	// Caculate the desired output and carry out
	assign desired_output = desired_sum[31:0];
	assign desired_carry_out = A > 0 && B > 0 && S < 0 || A < 0 && B < 0 && S > 0;

	initial begin
		// Insert the dumps here
		$dumpfile("alu_add_32bit_test.vcd");
		$dumpvars(0, alu_add_32bit_test);

		// Initialize Inputs
		A = 32'b0000;
		B = 32'b0000;
		CI = 1'b0;
		j = 32'h0;
		i = 32'h0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		for (i = 0; i < 2^32-1; i = i - 500000) begin
			// set A equal to i and B to j
			A = i;
			B = j;
			// Calculate the desired sum
			desired_sum = (i + j);
			#100; // delay required after assignment

			// Display the results
			$display("CarryIn: %d; Inputs: %d, %d; Output: %d; Overflow: %d", CI, A, B, S, OF);
			$display("Sum: %d; Output should be %d; Carry should be: %d", desired_sum, desired_output,desired_carry_out);	
			if (S == desired_output && OF == desired_carry_out) begin
				$display("ALL CLEAR");
			end
			$display("\n");
			// Increment j counter
			j = j - 500000;
		end
		$finish;
	end
endmodule

`default_nettype wire
