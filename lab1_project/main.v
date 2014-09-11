`timescale 1ns / 1ps  //sets the timescale (for simulation)

`default_nettype none //overrides default behaviour: errors when a net type is not declired

module main(switch, led);

//declare the inputs and outputs of our design
input  wire [7:0] switch;        //8 input switches
output wire [7:0] led;           //8 output leds

//connect the switches through inverters to the leds
assign led = ~switch;

endmodule

`default_nettype none //reengages default behaviour: needed for other Xilinx modules
