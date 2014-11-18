`timescale 1ns/1ps
`default_nettype none
module cpu(     );
	// Instantiate ALU component with inputs and outputs
	// ALU inputs
	reg [3:0] ALUControl;
	reg [31:0] SrcA, SrcB;
	// ALU outputs
	wire [31:0] ALUResult;
	wire Zero;
	behavioural_alu ALU (
		.X(SrcA), 
		.Y(SrcB), 
		.op_code(ALUControl), 
		.Z(ALUResult), 
		.zero(Zero)
	);

	// Instantiate register File
	// Register Inputs
	// Register Outputs
endmodule
`default_nettype wire
