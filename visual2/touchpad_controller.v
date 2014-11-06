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

// Dimension identifiers
`define X_ID 2'b01
`define Y_ID 2'b10
`define Z_ID 2'b01

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
	output reg [11:0] x,y,z
);

reg [4:0] clk_div_counter;
reg [1:0] current_dimension;
wire [7:0] transaction_message;

assign transaction_message[0] = 1'b1;
assign transaction_message[2:1] = current_dimension;
assign transaction_message[3] = 1'b1;
assign transaction_message[7:4] = 4'b0;

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
reg shift_out_rst;

shift_out SHIFT_OUT (
	.clk(touch_clk), 
	.data_in(transaction_message),
	.ena(shift_out_ena),
	.rst(shift_out_rst), 
	.data_out(data_out)
);

// Shift in module
wire shift_in_ena;
wire [11:0] touchpad_message;
reg shift_in_rst;

shift_in SHIFT_IN (
	.clk(touch_clk),
	.data_in(data_in), 
	.ena(shift_in_ena), 
	.rst(shift_in_rst), 
	.data_out(touchpad_message)
);

// Transaction counter
wire [31:0] transaction_counter;
reg counter_ena;
reg counter_rst;
counter TRANSACTION_COUNTER (
	.clk(touch_clk), 
	.rstb(counter_rst),
	.en(counter_ena), 
	.out(transaction_counter)
);

// Repetition counter
wire [31:0] repetition_counter;
reg repetition_counter_ena;
reg repetition_counter_rst;

counter REPETITION_COUNTER (
	.clk(counter_rst), 
	.rstb(repetition_counter_rst),
	.en(repetition_counter_ena), 
	.out(repetition_counter)
);

// Make the shift in and shift out counter enables dependent on the transaction
// counter
assign shift_out_ena = (transaction_counter >= `CALL_START && transaction_counter < `CALL_END);
assign shift_in_ena = (transaction_counter >= `RESPONSE_START && transaction_counter < `RESPONSE_END);

always @(*) begin
	if(rstb) begin
		counter_rst = (transaction_counter == `TRANSACTION_END);
		shift_out_rst = ~(transaction_counter == `TRANSACTION_END); // active low
		shift_in_rst = ~(transaction_counter == `TRANSACTION_END); // active low
		repetition_counter_rst = (repetition_counter == `REPETITION_END);
	end
end

always @(posedge repetition_counter_rst) begin
	case(current_dimension)
		`TOUCH_READ_X: begin
			current_dimension <= `TOUCH_READ_Y;
			x <= touchpad_message;
		end
		`TOUCH_READ_Y: begin
			current_dimension <= `TOUCH_READ_Z;
			y <= touchpad_message;
		end
		`TOUCH_READ_Z: begin
			current_dimension <= `TOUCH_READ_X;
			z <= touchpad_message;
		end
	endcase
end

always @(posedge cclk) begin
	if(~rstb) begin
		clk_div_counter <= 0;
		//data_out <= 0;
		touch_csb <= 1;
        current_dimension <= `TOUCH_READ_X;
		repetition_counter_ena = 1;
		// Make sure all the modules are reset
		counter_rst <= 1;
		repetition_counter_rst <= 1;
		shift_out_rst <= 0;
		shift_in_rst <= 0;
		touch_clk <= 0;
		counter_ena <= 1;
		// Initialize x,y,z values
		x <= 0;
		y <= 0;
		z <= 0;
		/*
		incoming_data <= 0;
		channel <= `TOUCH_READ_X;
		touch_tx_done <= 0;
		touch_rx_done <= 0;
		x_raw <= 0;
		y_raw <= 0;
		z_raw <= 0;
		state <= `TOUCH_STATE_RESET;
		tx_count <= 0;
		rx_count <= 0;
		channel_switch_count <= 0;
        */
	end
	else begin
		// Ensure that the touchpad controller gets a low csb signal
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
			end
		end
	end
end

endmodule
`default_nettype wire
