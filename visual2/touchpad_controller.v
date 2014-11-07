`timescale 1ns / 1ps
`default_nettype none
`ifndef TOUCH_DEFINES

`define TOUCH_DEFINES
`define TOUCH_CLK_DIV_COUNT 25
`define TOUCH_READ_X       2'b01
`define TOUCH_READ_Y       2'b00
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
`define CALL_END 8
`define RESPONSE_START 10
`define RESPONSE_END 23
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
	input wire touch_busy, data_in,
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
assign transaction_message[5:4] = 2'b00;
assign transaction_message[7:6] = 2'b11;

// Shift out module
wire shift_out_ena;
reg shift_out_rst;

shift_out SHIFT_OUT (
	.clk(cclk),
	.touch_clk(touch_clk), 
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
	.clk(cclk),
	.touch_clk(touch_clk),
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
	.clk(cclk),
	.touch_clk(touch_clk), 
	.rstb(counter_rst),
	.en(counter_ena), 
	.out(transaction_counter)
);

// Repetition counter
reg [31:0] repetition_counter;

// Make the shift in and shift out counter enables dependent on the transaction
// counter
assign shift_out_ena = (transaction_counter >= `CALL_START && transaction_counter < `CALL_END);
assign shift_in_ena = (transaction_counter >= `RESPONSE_START && transaction_counter < `RESPONSE_END);

always @(posedge cclk) begin
	if(~rstb) begin
		clk_div_counter <= 0;

		//data_out <= 0;
		touch_csb <= 1;
        current_dimension <= `TOUCH_READ_X;
		// Make sure all the modules are reset
		counter_rst = 1;
		shift_out_rst = 0;
		shift_in_rst = 0;

		touch_clk <= 0;
		counter_ena <= 1;
		repetition_counter <= 1;

		// Initialize x,y,z values
		x <= 12'd1000;
		y <= 12'd1000;
		z <= 12'd1000;
	end
	else begin
		// Ensure that the touchpad controller gets a low csb signal
		touch_csb <= 0;

		// Set reset signals
		counter_rst = (transaction_counter == `TRANSACTION_END);
		shift_out_rst = ~(transaction_counter == `TRANSACTION_END); // active low
		shift_in_rst = ~(transaction_counter == `TRANSACTION_END); // active low

		if(counter_rst) begin
			if( repetition_counter == `REPETITION_END ) begin
				case(current_dimension)
					`TOUCH_READ_X: begin
						current_dimension <= `TOUCH_READ_Y;
						x <= touchpad_message;
						//x <= 12'd1000;
					end
					`TOUCH_READ_Y: begin
						current_dimension <= `TOUCH_READ_Z;
						y <= touchpad_message;
						//y <= 12'd1000;
					end
					`TOUCH_READ_Z: begin
						current_dimension <= `TOUCH_READ_X;
						z <= touchpad_message;
						//x <= 12'd1000;
					end
				endcase
				repetition_counter <= 0;
			end
			else begin
				repetition_counter = repetition_counter + 1;
			end
		end

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
