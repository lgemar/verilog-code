`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    pwm_generator 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////

module pwm_generator(cclk, rstb, frequency_division, duty_cycle, pwm);
	input wire cclk, rstb;
	input wire [31:0] frequency_division; 
	input wire [31:0] duty_cycle;
	output reg pwm;

	// Internal wires
	wire wave_start, wave_end, duty_reset;
	assign duty_reset = ~wave_start; // reset signal is active low

	pulse_train PULSE1 (.cclk(cclk), .rstb(rstb), .X(frequency_division), .pulse(wave_start));
	pulse_train PULSE2 (.cclk(cclk), .rstb(duty_reset), .X(duty_cycle), .pulse(wave_end));

	`define LOW 1'b0
	`define HIGH 1'b1
	always @(posedge cclk) begin
		if( ~rstb ) begin
			pwm <= `LOW;
		end
		else begin
			case (pwm)
				`LOW : begin
					case ({wave_start, wave_end})
						2'b00 : pwm <= `LOW;
						2'b01 : pwm <= `LOW;
						2'b10 : pwm <= `HIGH;
						2'b11 : pwm <= `LOW;
					endcase
				end
				`HIGH : begin
					case ({wave_start, wave_end})
						2'b00 : pwm <= `HIGH;
						2'b01 : pwm <= `LOW;
						2'b10 : pwm <= `HIGH;
						2'b11 : pwm <= `HIGH;
					endcase
				end
			endcase
		end
	end
endmodule
`default_nettype wire
