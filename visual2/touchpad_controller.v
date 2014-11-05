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

`define TOUCH_X_ADJ_MIN 12'h096
`define TOUCH_X_POST_ADJ_MAX 12'hF6E

`define TOUCH_Y_ADJ_MIN 12'h12C
`define TOUCH_Y_POST_ADJ_MAX 12'hED8

`endif

module touchpad_controller(
	input wire cclk, rstb,
	input wire touch_busy,data_in,
	output reg touch_clk, data_out,
	output reg touch_csb,
	output reg [8:0] x,y,z
);

reg [4:0] clk_div_counter;

always @(posedge cclk) begin
	if(~rstb) begin
		clk_div_counter <= 0;
		channel <= `TOUCH_READ_X;
		touch_tx_done <= 0;
		touch_rx_done <= 0;
		x_raw <= 0;
		y_raw <= 0;
		z_raw <= 0;
		incoming_data <= 0;
		touch_clk <= 0;
		state <= `TOUCH_STATE_RESET;
		tx_count <= 0;
		rx_count <= 0;
		data_out <= 0;
		channel_switch_count <= 0;
		touch_csb <= 1;
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
			end
		end
	end
end

endmodule
`default_nettype wire
