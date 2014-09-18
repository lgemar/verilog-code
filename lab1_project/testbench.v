//timescale 1ns / 1ps

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

	integer i;
	initial begin
		// Insert the dumps here
		$dumpfile("testbench.vcd")
		$dumpvars(0,testbench)

		//set the switch to be one of every possible value
		for(i = 0; i < 8'hff; i = i + 1) begin
			switch=i;
			#10;
		end
		$finish;
	end
      
endmodule

`default_nettype wire
