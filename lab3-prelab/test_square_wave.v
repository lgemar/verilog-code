`timescale 1ns / 1ps
`default_nettype none

module test_square_wave;
        // Inputs
        reg clk;
        reg rstb;
        reg [31:0] duty_cycle;
        wire[31:0] freq_div  = 32'd10; 
 
        // Outputs
        wire out;
 
        // Instantiate the Unit Under Test (UUT)
        pwm_generator uut (
            .cclk(clk),
            .rstb(rstb),
            .duty_cycle(duty_cycle),
            .frequency_division(freq_div),           
            .pwm(out)
        );
 
        always #5 clk = ~clk;
 
        initial begin
            $dumpfile("test_square_wave.vcd");
            $dumpvars(0, test_square_wave);

            clk = 0;
            rstb = 0;
            duty_cycle = 8;

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
