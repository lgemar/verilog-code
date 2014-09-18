`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:44:43 09/18/2014
// Design Name:   mux_16to1
// Module Name:   C:/Documents and Settings/student/My Documents/final_project/Lab2-prelab/mux_16to1_test.v
// Project Name:  Lab2-prelab
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mux_16to1
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mux_16to1_test;

	// test module variables
	reg [3:0] i;
	// Inputs
	reg [3:0] A;
	reg [3:0] B;
	reg [3:0] C;
	reg [3:0] D;
	reg [3:0] E;
	reg [3:0] F;
	reg [3:0] G;
	reg [3:0] H;
	reg [3:0] I;
	reg [3:0] J;
	reg [3:0] K;
	reg [3:0] L;
	reg [3:0] M;
	reg [3:0] N;
	reg [3:0] O;
	reg [3:0] P;
	reg [3:0] S;

	// Outputs
	wire [3:0] Z;

	// Instantiate the Unit Under Test (UUT)
	mux_16to1 uut (
		.A(A), 
		.B(B), 
		.C(C), 
		.D(D), 
		.E(E), 
		.F(F), 
		.G(G), 
		.H(H), 
		.I(I), 
		.J(J), 
		.K(K), 
		.L(L), 
		.M(M), 
		.N(N), 
		.O(O), 
		.P(P), 
		.S(S), 
		.Z(Z)
	);

	initial begin
		// Insert the dumps here
		$dumpfile("mux_16to1_test.vcd");
		$dumpvars(0, mux_16to1_test);

		// Initialize Inputs
		i = 4'h0;
		A = 4'h0;
		B = 4'h1;
		C = 4'h2;
		D = 4'h3;
		E = 4'h4;
		F = 4'h5;
		G = 4'h6;
		H = 4'h7;
		I = 4'h8;
		J = 4'h9;
		K = 4'ha;
		L = 4'hb;
		M = 4'hc;
		N = 4'hd;
		O = 4'he;
		P = 4'hf;
		S = 4'b0000;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		for (i = 0; i < 16; i = i + 1) begin
			S = i;
			#100;
			$display("Input: %b ; Output; %b", S, Z);
			if (S == Z) begin
				$display("Input equals output: OK");
			end
		end
		$finish;
	end
      
endmodule

