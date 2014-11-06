`timescale 1ns/1ps
`default_nettype none

module test_counter;

	reg clk;
	wire [7:0] data = 0;
	reg rstb;
	reg en;
	wire [7:0] out;

	reg [10: 0] i;

	counter UTT ( 
		.clk(clk), 
		.data(data), 
		.rstb(rstb), 
		.en(en), 
		.out(out) 
	);

	always #10 clk = ~clk;

	always @(posedge clk) begin
		en = (i % 10 == 0);
		i = i + 1;
	end

	assign data = out;

	initial begin
		// Insert the dumps here
		$dumpfile("test_counter.vcd");
		$dumpvars(0, test_counter);

		clk = 0;
		rstb = 1;

		repeat(1000) begin
			@(posedge clk);
            $display("i = %d, out = %d\n", i, out);
		end
        $finish
	end

endmodule
`default_nettype wire
