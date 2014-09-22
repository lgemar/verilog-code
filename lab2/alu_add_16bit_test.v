`timescale 1ns / 1ps
`default_nettype none

module alu_add_16bit_test;

	reg [15:0] A;
	reg [15:0] B;
	reg CI;
	wire [15:0] S;
	wire CO;

	// testbench variables
	reg [15:0] i;
	reg [15:0] j;
	reg [16:0] desired_sum;
	wire [15:0] desired_output;
	wire desired_carry_out;
 
	alu_add_16bit uut( .A(A), .B(B), .CI(CI), .S(S), .CO(CO));

	// Caculate the desired output and carry out
	assign desired_output = desired_sum[15:0];
	assign desired_carry_out = desired_sum[16];

	initial begin
		// Insert the dumps here
		$dumpfile("alu_add_16bit_test.vcd");
		$dumpvars(0, alu_add_16bit_test);

		// Initialize Inputs
		A = 16'h0000;
		B = 16'h0000;
		CI = 1'b0;
		j = 16'h0000;
		i = 16'h0000;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		for (i = 0; i < 65536; i = i + 1) begin
			// set A equal to i and B to j
			A = i;
			B = j;
			// Calculate the desired sum
			desired_sum = (i + j);
			#100;
			// Display the results
			$display("CarryIn: %d; Inputs: %d, %d; Output: %d; CarryOut: %d", CI, A, B, S, CO);
			$display("Sum: %d; Output should be %d; Carry should be: %d", 
					desired_sum, desired_output,desired_carry_out);	
			$display("\n");
			// Increment j counter
			j = j + 1;
		end
		$finish;
	end
endmodule

`default_nettype wire
