`timescale 1ns / 1ps
module sign_extend_test;

	// module inputs and outputs
	reg [15:0] instr;
	wire [31:0] SignImm;

	// Test module vars
	reg [31:0] incr;

	// Instantiate the Unit Under Test (UUT)
	sign_extend uut (
		.instr(instr), 
		.SignImm(SignImm)
	);

	initial begin
		// Insert the dumps here
		$dumpfile("sign_extend_test.vcd");
		$dumpvars(0, sign_extend_test);

		// Initialize Inputs
		incr = 2^10;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		for (instr = 0; ; instr = instr + incr) begin
			#100;
			$display("Inputs: %16b ; Output: %32b", instr, SignImm);
		end
		$finish;
	end
endmodule

