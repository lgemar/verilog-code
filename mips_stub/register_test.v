`timescale 1ns / 1ps

module register_test;

	// UUT inputs and outputs
	reg rst, clk, write_enable;
	reg [4:0] a1, a2, a3;
	reg [31:0] write_data;
	wire [31:0] read_data1, read_data2;
	
	// Test modules variables
	reg [31:0] j;
	

	// Instantiate the Unit Under Test (UUT)
	register uut (
		.rst(rst), 
		.clk(clk), 
		.write_ena(write_enable), 
		.address1(a1), 
		.address2(a2), 
		.address3(a3), 
		.write_data(write_data), 
		.read_data1(read_data1), 
		.read_data2(read_data2)
	);

	always #10 clk = ~clk;

	// Change the read values
	always @(posedge clk) begin
		// Reset the read addresses every 32nd clock cycle
		if(j % 17 == 0) begin
			a1 <= 5'd0;
			a2 <= 5'd0;
			a3 <= j;
		end
		else begin
			a1 <= a1 + 1;
			a2 <= a2 - 1;
			a3 <= j;
		end
	end

	always @(posedge clk) begin
		// Update the write addresses every 32nd clk cycle
		if(j % 17 == 0) begin
			write_enable <= 1;
			write_data = j;
			j <= j + 1;
		end
		else begin
			write_enable <= 0;
			write_data <= j;
			j <= j + 1;
		end
	end

	initial begin
		// Insert the dumps here
		$dumpfile("register_test.vcd");
		$dumpvars(0, register_test);


		// Initialize test bench vars
		j = 0;

		// Initialize UUT inputs
		rst = 1;
		clk = 0;
		write_enable = 0;
		write_data = 0;
		a1 = 0;
		a2 = 0;
		a3 = 0;

		// Wait 100 ns for global reset to finish
		#100;

		// Reset the module
		rst = 0;
		#50
		rst = 1;
        
		// Add stimulus here
		repeat(1000) begin
			@(posedge clk);
		end
		$finish;
	end
endmodule

