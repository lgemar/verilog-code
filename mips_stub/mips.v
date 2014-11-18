`timescale 1ns/1ps

`default_nettype none

module mips(clk, rstb, mem_wr_data, mem_addr, mem_rd_data, mem_wr_ena, PC);

	input wire clk, rstb;
	input wire [31:0] mem_rd_data;             
	output reg mem_wr_ena;
	output wire [31:0] mem_wr_data, mem_addr;
	output reg [31:0] PC;
		
	// Instantiate the Memory Unit and its inputs and outputs
	// Memory inputs
	// Memory outputs

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
	// clk, rstb are already instantiated
	wire [4:0] a1, a2, a3;
	wire we3;
	wire [31:0] wd3;
	// Register Outputs
	wire [31:0] rd1, rd2;
	// Assign and initialize inputs
	assign a1 = mem_rd_data[25:21];
	register REG (
		.rst(rstb), 
		.clk(clk), 
		.write_ena(we3), 
		.address1(a1), 
		.address2(a2), 
		.address3(a3),
		.write_data(wd3), 
		.read_data1(rd1), 
		.read_data2(rd2)
	);


assign mem_addr = 32'h4000 + PC;
assign mem_wr_data = 0;

always@(posedge clk) begin
	if(~rstb) begin
		mem_wr_ena <= 0;
		PC <= 0;
	end
	else begin
		PC <= PC + 4; // test PC interaction with the memory read address
	end
end

endmodule

`default_nettype wire
