`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    pulse_train 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////

module pulse_train(clk, rstb, X, pulse);
    //define inputs
    input wire clk, rstb; //all fsms will have clock and reset
    input wire [7:0] X; //the input that determines how often the pulse will happen (lower is more frequent)
    output wire pulse;
     
    reg [7:0] count; //our state variable
     
    //pulse is an output of the FSM, so make sure to drive it outside of the always block!
    //only transitional logic and flip flop related statements should go inside always blocks
    assign pulse = (count == X);  //this creates an equals combinational logic structure for us - this is a bit behavioural, but actually better.
     
    //only the transitional logic goes in the always block
    always @(posedge clk) begin
        if(~rstb) begin //always take care of the reset first
            count <= 8'd0;  //reset the count to a known state (zero)
        end
        else begin //out of reset
            //the mux is created by the if statement
            if(count == X) begin
                count <= 8'd0; //be careful to size your constants properly
            end
            else begin
                count <= count + 8'd1;  //Xilinx will put a nice combinational adder here for you
            end
        end
    end
endmodule
`default_nettype wire
