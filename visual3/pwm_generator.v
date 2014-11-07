`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    pwm_generator
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////

module pwm_generator(cclk, rstb, frequency_division, duty_cycle, pwm);
    //define inputs
    input wire cclk, rstb; //all fsms will have clock and reset
    input wire [31:0] frequency_division; //the input that determines how often the pwm will happen (lower is more frequent)
	input wire [7:0] duty_cycle;
    output wire pwm;
     
    reg [31:0] count; //our state variable
     
    //pwm is an output of the FSM, so make sure to drive it outside of the always block!
    //only transitional logic and flip flop related statements should go inside always blocks
    assign pwm = (count < frequency_division) && (count < duty_cycle);  //this creates an equals combinational logic structure for us - this is a bit behavioural, but actually better
     
    //only the transitional logic goes in the always block
    always @(posedge cclk) begin
        if(~rstb) begin //always take care of the reset first
            count <= 31'd0;  //reset the count to a known state (zero)
        end
        else begin //out of reset
            //the mux is created by the if statement
            if(count == (frequency_division - 1)) begin
                count <= 31'd0; //be careful to size your constants properly
            end
            else begin
                count <= count + 31'd1;  //frequency_divisionilinx will put a nice combinational adder here for you
            end
        end
    end
endmodule
`default_nettype wire
