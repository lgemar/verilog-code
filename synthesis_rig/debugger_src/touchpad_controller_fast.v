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
`define S_RESET      2'd0
`define S_TXING      2'd1
`define S_RXING      2'd2

`define TOUCH_X_ADJ_MIN 12'h096
`define TOUCH_X_POST_ADJ_MAX 12'hF6E

`define TOUCH_Y_ADJ_MIN 12'h12C
`define TOUCH_Y_POST_ADJ_MAX 12'hED8

`endif

module touchpad_controller_fast(
	input wire cclk, rstb,
	input wire touch_busy,data_in,
	output wire touch_clk, data_out,
	output reg touch_csb,
	output reg [8:0] x,y,z
);

reg [4:0] clk_div_counter;
reg [1:0] channel;
reg [11:0] x_raw, y_raw, z_raw, incoming_data;
wire [8:0] x_filtered, y_filtered, z_filtered;
wire [8:0] x_prefilter, y_prefilter, z_prefilter;
wire x_raw_changed, y_raw_changed, z_raw_changed;
wire [11:0] x_adj;
wire [11:0] y_adj;
wire [11:0] x_scaled, y_scaled;
reg [1:0] state;

assign x_raw_changed = (rx_done) & (channel == `TOUCH_READ_X) & &channel_switch_count;
assign y_raw_changed = (rx_done) & (channel == `TOUCH_READ_Y) & &channel_switch_count;
assign z_raw_changed = (rx_done) & (channel == `TOUCH_READ_Z) & &channel_switch_count;

assign x_adj = (x_raw > `TOUCH_X_ADJ_MIN) ? x_raw - `TOUCH_X_ADJ_MIN : 12'h0;
assign y_adj = (y_raw > `TOUCH_Y_ADJ_MIN) ? y_raw - `TOUCH_Y_ADJ_MIN : 12'h0;

assign x_scaled = (x_adj>>3);
assign y_scaled = (y_adj>>4) + (y_adj>>6);

assign x_prefilter = (x_scaled[8:0] > 9'd479) ? 9'd479 : x_scaled[8:0];
assign y_prefilter = (y_scaled[8:0] > 9'd272) ? 9'd272 : y_scaled[8:0];
assign z_prefilter = z_raw[11:3];

averager #(.N(9), .M(10)) FILTER_X (.raw(x_prefilter), .averaged(x_filtered), .ena(x_raw_changed), .cclk(cclk), .rstb(rstb));
averager #(.N(9), .M(10)) FILTER_Y (.raw(y_prefilter), .averaged(y_filtered), .ena(y_raw_changed), .cclk(cclk), .rstb(rstb));
averager #(.N(9), .M(10)) FILTER_Z (.raw(z_prefilter), .averaged(z_filtered), .ena(z_raw_changed), .cclk(cclk), .rstb(rstb));

always @(*) begin
	x = x_filtered;
	y = y_filtered;
	z = z_filtered;
end

wire [7:0] tx_buffer;
wire [11:0] rx_buffer;
assign tx_buffer[7] = 1'b1; //start bit
assign tx_buffer[6] = (channel == `TOUCH_READ_X); //addr2
assign tx_buffer[5] = (channel == `TOUCH_READ_Z); //addr1
assign tx_buffer[4] = 1'b1; //addr0
assign tx_buffer[3] = 1'b0;
assign tx_buffer[2] = 1'b0;
assign tx_buffer[1] = 1'b1;
assign tx_buffer[0] = 1'b1;

reg [2:0] channel_switch_count;

//this module handles sending/receiving bytes on an SPI like protocol
reg tx_start;
wire tx_done, rx_done;
ussrt #(
	.CLK_DIVIDER(`TOUCH_CLK_DIV_COUNT),
	.TX_N(8),
	.RX_N(12),
	.TX_EDGE(1'b0), //tx on negative edges
	.RX_EDGE(1'b1), //rx on positive edges
	.TX_MSB_FIRST(1), 
	.RX_MSB_FIRST(1)
) AD7873_INTERFACE (
	.clk(cclk),
	.rstb(rstb),
	.sclk(touch_clk),
	.csb(touch_csb),
	.tx(tx_buffer),
	.rx(rx_buffer),
	.dout(data_out),
	.din(data_in),
	.tx_start(tx_start),
	.tx_busy(0),
	.rx_busy(touch_busy),
	.tx_done(tx_done),
	.rx_done(rx_done)
);

always @(posedge cclk) begin
	if(~rstb) begin
		channel <= `TOUCH_READ_X;
		x_raw <= 0;
		y_raw <= 0;
		z_raw <= 0;
		state <= `S_RESET;
		channel_switch_count <= 0;
		tx_start <= 0;
		touch_csb <= 1;
	end
	else begin
		touch_csb <= 0;
		case(state)
			`S_RESET : begin
				tx_start <= 1;
				state <= `S_TXING;
			end
			`S_TXING : begin			
				if(tx_done) begin
					tx_start <= 0;
					state <= `S_RXING;
				end
			end
			`S_RXING : begin
				if(rx_done) begin
					channel_switch_count <= channel_switch_count + 3'd1;
					//change channel
					if(&channel_switch_count) begin
						//save incoming data
						case(channel)
							`TOUCH_READ_X : x_raw <= rx_buffer;
							`TOUCH_READ_Y : y_raw <= rx_buffer;
							`TOUCH_READ_Z : z_raw <= rx_buffer;
						endcase
						case(channel)
							`TOUCH_READ_X : channel <= `TOUCH_READ_Y;
							`TOUCH_READ_Y : channel <= `TOUCH_READ_Z;
							default       : channel <= `TOUCH_READ_X;
						endcase 
					end
					tx_start <= 1;
					state <= `S_TXING;
				end
			end
		endcase
	end
end

endmodule
`default_nettype wire
