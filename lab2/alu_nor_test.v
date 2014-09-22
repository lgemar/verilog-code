`timescale 1ns / 1ps
`default_nettype none

module alu_nor_test;
	reg [31:0] i1;
	reg [31:0] i2; 
	reg [3:0] i;
	wire [31:0] Z;		
 
	parameter WIDTH = 32; 
	
	alu_nor #(.WIDTH(WIDTH)) uut( .A(i1), .B(i2), .Z(Z));

	initial begin
		// Initialize Inputs
		i1 = 32'h00000000;
		i2 = 32'hffffffff;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		for (i = 0; i < 8; i = i + 1) begin
			i2 = i2 << 2;
			#100;
		end
		$finish;
	end
endmodule

`default_nettype wire
