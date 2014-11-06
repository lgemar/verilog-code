`timescale 1ns/1ps
`default_nettype none

module test_counter;

	reg clk;
	reg [7:0] data;
	reg rstb;
	reg en;
	wire [7:0] out;

	reg [10: 0] i;

	counter utt ( 
		.clk(clk), 
		.data(data), 
		.rstb(rstb), 
		.en(en), 
		.out(out) 
	);

	assign data = out;

	initial begin
		// Insert the dumps here
		$dumpfile("test_counter.vcd");
		$dumpvars(0, test_counter);

		clk = 0;
		rstb = 0;	

		for (i = 0; i < 2045; i = i + 1) begin
			clk = ~clk;
			if (i % 4 == 0) 
				en = 1;
			else 
				en = 0;
			$display("i = %d, out = %d\n", i, out);
		end
		$finish;
	end

endmodule
`default_nettype wire
