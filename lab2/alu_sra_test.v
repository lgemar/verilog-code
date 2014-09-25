`timescale 1ns / 1ps
`default_nettype none

module alu_sra_test;

	reg [31:0] A;
	reg [31:0] B;
	wire [31:0] Z;

	reg [5:0] i;
	parameter SHIFT = 1;

	alu_sra uut( .A(A), .Z(Z));

	initial begin
		// Insert the dumps here
		$dumpfile("alu_sra_test.vcd");
		$dumpvars(0, alu_sra_test);

		// Initialize Inputs
		A = 32'hffffffff;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		for (i = 0; i < 32; i = i + 1) begin
			A = $signed(A >>> 1);
			#100;
			// Display the results
			$display("A: %d; Z: %b", A, Z);
		end
		$finish;
	end
endmodule

`default_nettype wire
