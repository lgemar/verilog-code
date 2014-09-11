`timescale 1ns / 1ps

`default_nettype none //forces xilinx to catch undeclared wires

//the following module is made for SIMULATION ONLY - most of the language
//constructs used here will not synthesize, but will simulate
module testbench;

	// Inputs
	reg [7:0] switch;
	// Outputs
	wire [7:0] led;

	// Instantiate the Unit Under Test (UUT)
	main uut (
		.switch(switch), 
		.led(led)
	);

	initial begin
		// Insert the dumps here
		$dumpfile("testbench.v")
		$dumpvars(0,uut)

		//set the switch to be one of every possible value
		for(switch = 0; switch < 8'hff; switch = switch + 1) begin
			#10;
		end
		$finish;
	end
      
endmodule

`default_nettype wire
