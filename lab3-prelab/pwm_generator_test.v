`timescale 1ns / 1ps
`default_nettype none

module pwm_generator_test;
        // Inputs
        reg clk;
        reg rstb;
        reg [7:0] duty_cycle;
        wire[31:0] freq_div  = 32'd10; 
 
        // Outputs
        wire out;
 
        // Instantiate the Unit Under Test (UUT)
        pwm_generator uut (
            .cclk(clk),
            .rstb(rstb),
            .frequency_division(freq_div),           
            .duty_cycle(duty_cycle),
            .pwm(out)
        );
 
        always #5 clk = ~clk;
 
        initial begin
            $dumpfile("pwm_generator_test.vcd");
            $dumpvars(0, pwm_generator_test);

            clk = 0;
            rstb = 0;
            duty_cycle = 7;

			#50;
			rstb = 1;
			#50;

            repeat (256) @(posedge clk) begin
				$display("%d", out);
			end

            $finish;
        end
 
endmodule

`default_nettype wire
