`timescale 1ns/1ps
`default_nettype none

module test_counter;

	reg clk;
	reg rstb;
	reg en;
	wire [7:0] out;

	reg [10:0] i;

	counter UTT ( 
		.clk(clk), 
		.rstb(rstb), 
		.en(en), 
		.out(out) 
	);

	initial begin
		// Insert the dumps here
		$dumpfile("test_counter.vcd");
		$dumpvars(0, test_counter);

		clk = 0;
		rstb = 1;
        i = 0;
		repeat(1000) begin
			@(posedge clk);
            #10;
            i = i + 1;
            $display("i = %d, out = %d\n", i, out);
		end
        $finish
	end

endmodule
`default_nettype wire
