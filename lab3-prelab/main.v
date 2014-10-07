`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    main 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////


module main(cclk, rstb, switch, led);
	//port definitions
	input wire cclk, rstb;
	input wire [7:0] switch;
	output wire [7:0] led;
	
	// Since we don't have enough switches to control this parameter, we'll hardcode it.
	wire[31:0] freq_div  = 32'd10; // feel free to replace this with your own.
	
	// Replace with your pwm module, but MAKE SURE the interface is the exact same. 
	// Do not rename input or output wires; this creates nightmares for grading and testing.
	pwm_generator PWM0(.cclk(cclk), .rstb(rstb), .duty_cycle(switch), .frequency_division(freq_div), .pwm(led[0]));
	
	//your leds should vary in intensity as you change the switches!
	assign led[7:1] = {7{led[0]}};
	
endmodule
`default_nettype wire
