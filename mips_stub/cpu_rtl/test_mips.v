`timescale 1ns / 1ps
`default_nettype none
module test_mips;

	// Inputs
	reg clk;
	reg rstb;

	// Outputs
	wire [31:0] mem_rd_data;
	wire [31:0] mem_wr_data;
	wire [31:0] mem_addr;
	wire mem_wr_ena;
	wire [31:0] PC;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk(clk), 
		.rstb(rstb), 
		.mem_wr_data(mem_wr_data), 
		.mem_addr(mem_addr), 
		.mem_rd_data(mem_rd_data), 
		.mem_wr_ena(mem_wr_ena), 
		.PC(PC)
	);
	
	memory #(.in_file("in.machine"), .out_file("out.machine")) 
	MEMORY (
		.cpu_clk(clk), .cpu_mem_addr(mem_addr), .cpu_mem_wr_ena(mem_wr_ena), .cpu_mem_wr_data(mem_wr_data), .cpu_mem_rd_data(mem_rd_data)
	);
	initial begin
		// Insert the dumps here
		$dumpfile("test_mips.vcd");
		$dumpvars(0, test_mips);

		// Initialize Inputs
		clk = 0;
		rstb = 0;

		//reset
		repeat (5) @(posedge clk);
		rstb = 1;
		//run for some clocks
		repeat(100) @(posedge clk);
      //dump the memory
		MEMORY.dump();
		$finish;
	end
	
	always #5 clk = ~clk;
      
endmodule

`default_nettype wire
