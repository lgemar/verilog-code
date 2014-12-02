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
reg [1:0] channel;
reg touch_tx_done, touch_rx_done;
reg [11:0] x_raw, y_raw, z_raw, incoming_data;
wire [8:0] x_filtered, y_filtered, z_filtered;
wire [8:0] x_prefilter, y_prefilter, z_prefilter;
wire x_raw_changed, y_raw_changed, z_raw_changed;
wire [11:0] x_adj;
wire [11:0] y_adj;
wire [11:0] x_scaled, y_scaled;
reg [8:0] state, tx_count, rx_count;

assign x_raw_changed = (state == `TOUCH_STATE_RX_DONE) & (channel == `TOUCH_READ_X) & &channel_switch_count;
assign y_raw_changed = (state == `TOUCH_STATE_RX_DONE) & (channel == `TOUCH_READ_Y) & &channel_switch_count;
assign z_raw_changed = (state == `TOUCH_STATE_RX_DONE) & (channel == `TOUCH_READ_Z) & &channel_switch_count;

assign x_adj = (x_raw > `TOUCH_X_ADJ_MIN) ? x_raw - `TOUCH_X_ADJ_MIN : 12'h0;
assign y_adj = (y_raw > `TOUCH_Y_ADJ_MIN) ? y_raw - `TOUCH_Y_ADJ_MIN : 12'h0;

assign x_scaled = (x_adj>>3);
assign y_scaled = (y_adj>>4) + (y_adj>>6);

assign x_prefilter = (x_scaled[8:0] > 9'd479) ? 9'd479 : x_scaled[8:0];
assign y_prefilter = (y_scaled[8:0] > 9'd272) ? 9'd272 : y_scaled[8:0];
assign z_prefilter = z_raw[11:3];

averager #(.N(9), .M(8)) FILTER_X (.raw(x_prefilter), .averaged(x_filtered), .ena(x_raw_changed), .cclk(cclk), .rstb(rstb));
averager #(.N(9), .M(8)) FILTER_Y (.raw(y_prefilter), .averaged(y_filtered), .ena(y_raw_changed), .cclk(cclk), .rstb(rstb));
averager #(.N(9), .M(8)) FILTER_Z (.raw(z_prefilter), .averaged(z_filtered), .ena(z_raw_changed), .cclk(cclk), .rstb(rstb));

always @(*) begin
	x = x_filtered;
	y = y_filtered;
end

wire [7:0] tx_message;
assign tx_message[0] = 1'b1; //start bit
assign tx_message[1] = (channel == `TOUCH_READ_X); //addr2
assign tx_message[2] = (channel == `TOUCH_READ_Z); //addr1
assign tx_message[3] = 1'b1; //addr0
assign tx_message[4] = 1'b0;
assign tx_message[5] = 1'b0;
assign tx_message[6] = 1'b1;
assign tx_message[7] = 1'b1;

reg [2:0] channel_switch_count;

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
				//drive tx_count and data_out
				if((state == `TOUCH_STATE_TXING) && (tx_count <= 9'd7)) begin
					tx_count <= tx_count + 1;
					data_out <= tx_message[tx_count];
				end
				else begin
					tx_count <= 0;
					data_out <= 0;
				end
				//drive state
				case (state)
					`TOUCH_STATE_RESET   : state <= `TOUCH_STATE_TXING;
					`TOUCH_STATE_TXING   : state <= (tx_count <= 9'd7 ) ? `TOUCH_STATE_TXING : `TOUCH_STATE_RXING;
				endcase

			end
			if(~touch_clk) begin //positive edge logic
				//drive rx_count, get data
				if(state == `TOUCH_STATE_RXING) begin
					if(~touch_busy) begin
						rx_count <= rx_count + 1;
						incoming_data[11-rx_count] <= data_in;
					end
				end
				else begin
					rx_count <= 0;
				end
				if(state == `TOUCH_STATE_RX_DONE) begin
					channel_switch_count <= channel_switch_count + 3'd1;
					//change channel
					if(&channel_switch_count) begin
						//save incoming data
						case(channel)
							`TOUCH_READ_X : x_raw <= incoming_data;
							`TOUCH_READ_Y : y_raw <= incoming_data;
							`TOUCH_READ_Z : z_raw <= incoming_data;
						endcase
						case(channel)
							`TOUCH_READ_X : channel <= `TOUCH_READ_Y;
							`TOUCH_READ_Y : channel <= `TOUCH_READ_Z;
							default       : channel <= `TOUCH_READ_X;
						endcase 
					end
				end
				
				//drive state
				case (state)
					`TOUCH_STATE_RXING   : state <= (rx_count <= 11) ? `TOUCH_STATE_RXING : `TOUCH_STATE_RX_DONE;
					`TOUCH_STATE_RX_DONE : state <= `TOUCH_STATE_RESET;
				endcase
			end
		end
	end
end

endmodule
`default_nettype wire
