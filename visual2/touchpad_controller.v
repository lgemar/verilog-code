`timescale 1ns / 1ps
`default_nettype none
`ifndef TOUCH_DEFINES

`define TOUCH_DEFINES
`define TOUCH_CLK_DIV_COUNT 25
`define TOUCH_READ_X       2'b00
`define TOUCH_READ_Y       2'b01
`define TOUCH_READ_Z       2'b10
`define TOUCH_READ_INVALID 2'b11

//fsm states
`define TOUCH_STATE_RESET      0
`define TOUCH_STATE_TX_START   1
`define TOUCH_STATE_TXING      2
`define TOUCH_STATE_BUSY       3
`define TOUCH_STATE_RXING      4
`define TOUCH_STATE_RX_DONE    5
`define TOUCH_STATE_RX_WAIT    6

// Transaction states
`define CALL_START 0
`define CALL_END 9
`define RESPONSE_START 9
`define RESPONSE_END 22
`define TRANSACTION_END 24

// Repetition States
`define REPETITION_END 16


`define TOUCH_X_ADJ_MIN 12'h096
`define TOUCH_X_POST_ADJ_MAX 12'hF6E

`define TOUCH_Y_ADJ_MIN 12'h12C
`define TOUCH_Y_POST_ADJ_MAX 12'hED8

`endif

module touchpad_controller(
	input wire cclk, rstb,
	input wire touch_busy,data_in,
	output reg touch_clk,
	output wire data_out,
	output reg touch_csb,
	output reg [8:0] x,y,z
);

reg [4:0] clk_div_counter;

/**
// Hardcode in values for x, y, and z
always @(*) begin
	x = 12'd1000;
	y = 12'd1000;
	z = 12'b1110_0000_0000;
end
*/

// Shift out module
wire shift_out_ena;
reg [7:0] touch_message;
wire shift_out_rst;

shift_out SHIFT_OUT (
	.clk(touch_clk), 
	.data_in(touch_message),
	.ena(shift_out_ena),
	.rst(shift_out_rst), 
	.data_out(data_out)
);

// Shift in module
wire shift_in_ena;
wire [11:0] touchpad_message;
wire shift_in_rst;

shift_in SHIFT_IN (
	.clk(touch_clk),
	.data_in(data_in), 
	.ena(shift_in_ena), 
	.rst(shift_in_rst), 
	.data_out(touchpad_message)
);

// Transaction counter
wire [31:0] transaction_counter;
wire counter_rst;
wire counter_ena;
counter TRANSACTION_COUNTER (
	.clk(touch_clk), 
	.rstb(counter_rst),
	.en(counter_ena), 
	.out(transaction_counter)
);

// Repetition counter
wire [31:0] repetiion_counter;
wire repetition_counter_rst;
reg repetition_counter_ena;
counter REPETITION_COUNTER (
	.clk(counter_rst), 
	.rstb(repetition_counter_rst),
	.en(repetition_counter_ena), 
	.out(repetiion_counter)
);

// Make the shift in and shift out counter enables dependent on the transaction
// counter
assign shift_out_ena = (transaction_counter >= `CALL_START && transaction_counter < `CALL_END);
assign shift_in_ena = (transaction_counter >= `RESPONSE_START && transaction_counter < `RESPONSE_END);
assign counter_rst = (transaction_counter == `TRANSACTION_END);
assign shift_out_rst = ~(transaction_counter == `TRANSACTION_END); // active low
assign shift_in_rst = ~(transaction_counter == `TRANSACTION_END); // active low
assign repetition_counter_rst = (repetiion_counter == RESPONSE_END);

always @(posedge cclk) begin
	if(~rstb) begin
		clk_div_counter <= 0;
		/**
		channel <= `TOUCH_READ_X;
		touch_tx_done <= 0;
		touch_rx_done <= 0;
		x_raw <= 0;
		y_raw <= 0;
		z_raw <= 0;
		incoming_data <= 0;
		state <= `TOUCH_STATE_RESET;
		tx_count <= 0;
		rx_count <= 0;
		channel_switch_count <= 0;
		*/
		//data_out <= 0;
		touch_clk <= 0;
		touch_csb <= 1;

		// Make sure private member variables are initialized
		repetition_counter_ena = 1;
	end
	else begin
		touch_csb <= 0;
		if(clk_div_counter != (`TOUCH_CLK_DIV_COUNT-1)) begin
			clk_div_counter <= clk_div_counter + 6'd1;
		end
		else begin
			clk_div_counter <= 0;
			touch_clk <= ~touch_clk;
			if(touch_clk) begin  //negative edge logic
				/* put all of your negative edge logic here */
			end
			if(~touch_clk) begin //positive edge logic
				/* put all of your positive edge logic here */
				if(repetition_counter == 10) begin
				end
			end
		end
	end
end

endmodule
`default_nettype wire
