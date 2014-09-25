`timescale 1ns / 1ps
`default_nettype none

module alu_srl_test;

	reg [31:0] A;
	wire [31:0] Z;

	reg [5:0] i;
	parameter SHIFT = 1;

	alu_srl #(.SHIFT(SHIFT)) uut( .A(A), .Z(Z));

	initial begin
		// Insert the dumps here
		$dumpfile("alu_srl_test.vcd");
		$dumpvars(0, alu_srl_test);

		// Initialize Inputs
		A = 32'hffffffff;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		for (i = 0; i < 32; i = i + 1) begin
			A = A >> 1;
			#100;
			// Display the results
			$display("A: %x; Z: %b", A, Z);
		end
		$finish;
	end
endmodule

`default_nettype wire
