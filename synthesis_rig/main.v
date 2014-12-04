`timescale 1ns / 1ps

`default_nettype none //makes undeclared nets errors instead of automatic wires

`include "tft_defines.v"
`define SYNTHESIS
module main(
	//default IO
	input wire unbuf_clk, rstb_button,
	input wire [7:0] switch,
	output wire [7:0] led,
	output wire [7:0] JB,
	input wire button_up, button_down, button_right, button_left, button_center,
	//tft IO
	output wire tft_backlight, tft_clk, tft_data_ena,
	output wire tft_display,tft_vdd,
	output wire [7:0] tft_red, tft_green, tft_blue,
	//touchpad IO
	input wire touch_busy, touch_data_out,
	output wire touch_csb, touch_clk, touch_data_in
);

parameter N = 32;


//clocking signals
wire cclk, cclk_n, tft_clk_buf, tft_clk_buf_n, clocks_locked;
wire rst, rstb;
//debounce to the nearest 250ms (critical that this is longer than the cpu single step debouncer)
debouncer #(.CYCLES(25_000_000), .COUNTER_WIDTH(32), .RESET_VALUE(1'b0) ) DEBOUNCE_RSTB ( 
	.clk(cclk), .rst(1'b0), .bouncy(rstb_button), .debounced(rstb)
);
assign rst = ~rstb;
//generate all the clocks
clock_generator CLOCK_GEN (.clk100M_raw(unbuf_clk), .clk100M(cclk), .clk9M(tft_clk_buf), .clk9Mn(tft_clk_buf_n));
ODDR2 tft_clk_fixer (.D0(1'b1), .D1(1'b0), .C0(tft_clk_buf), .C1(tft_clk_buf_n), .Q(tft_clk), .CE(1'b1));  //pass the tft_clk through a DDR2 output buffer (so that it can drive external loads and so that internal loads are unaffected by large skew routing)

//memory
wire [N-1:0] mem_addr0, mem_rd_addr0, mem_wr_data0, mem_wr_addr1, mem_rd_addr1, mem_wr_data1, mem_addr1;
wire [N-1:0] mem_rd_data0, mem_rd_data1;
wire mem_wr_ena0, mem_wr_ena1;

assign mem_addr1 = mem_wr_ena1 ? mem_wr_addr1 : mem_rd_addr1;
synth_dual_port_memory #(
	.N(32),
	.I_LENGTH(256),
	.D_LENGTH(513),
	.I_WIDTH(8),
	.D_WIDTH(10)
) MEMORY(
	.clk(tft_clk_buf),
	.rstb(rstb),
	.wr_ena0(mem_wr_ena0),
	.addr0(mem_addr0),
	.din0(mem_wr_data0),
	.dout0(mem_rd_data0),
	.wr_ena1(mem_wr_ena1),
	.addr1(mem_addr1),
	.din1(mem_wr_data1),
	.dout1(mem_rd_data1)
);

//mips core
wire [31:0] PC;
wire single_step_mode, core_ena, single_step, single_step_active;
//debounce to the nearest 100ms, start in single step mode
debouncer #(.CYCLES(10_000_000), .COUNTER_WIDTH(32), .RESET_VALUE(1'b1)) DEBOUNCE_SW0 ( 
	.clk(cclk), .rst(rst), .bouncy(switch[7]), .debounced(single_step_mode)
);
//1 second one-shot on button (one shot takes care of debouncing issues)  Will execute 2 instructions per second
wire button_center_down;
assign button_center_down = button_center;
one_shot #(.PULSE_WIDTH(1), .DEAD_TIME(50_000_000), .COUNTER_WIDTH(32)) ONESHOT (
	.clk(cclk), .rst(rst), .trigger(button_center_down), .pulse(single_step), .one_shot(single_step_active)
);
assign core_ena = single_step_mode ? single_step : 1'b1;
assign led[7] = single_step_active | (~single_step_mode);
wire [32*32-1:0] full_register_file;

/* NOTE: CHANGE THE NAME OF YOUR CPU HERE */
mips CORE (
	.clk(tft_clk_buf),
	.rstb(rst),
	.ena(core_ena),
	.PC(PC),
	.mem_addr(mem_addr0),
	.mem_rd_data(mem_rd_data0),
	.mem_wr_data(mem_wr_data0),
	.mem_wr_ena(mem_wr_ena0),
	.full_register_file(full_register_file)
);

//mips debugger
mips_debugger DEBUGGER(
	.clk(tft_clk_buf),
	.rstb(rstb),
	.PC(PC),
	.full_register_file(full_register_file),
	.tft_x(tft_x),
	.tft_y(tft_y),
	.tft_new_frame(tft_new_frame),
	.color(color),
	.mem_rd_data(mem_rd_data1),
	.mem_rd_addr(mem_rd_addr1),
	.mem_wr_ena(mem_wr_ena1),
	.mem_wr_addr(mem_wr_addr1),
	.mem_wr_data(mem_wr_data1),
	.ram_colors(switch[0]),
	.core_ena(core_ena)
);


//tft/touchpad
wire [8:0] touch_x, touch_y, touch_z;
wire [9:0] tft_x;
wire [8:0] tft_y;
wire tft_new_frame;
wire [(`TFT_BITS_PER_PIXEL-1):0] color;

tft_driver TFT(
	.tft_clk(tft_clk_buf),
	.rstb(rstb),
	.tft_backlight(tft_backlight),
	.tft_data_ena(tft_data_ena),
	.tft_display(tft_display),
	.tft_vdd(tft_vdd),
	.tft_red(tft_red),
	.tft_green(tft_green),
	.tft_blue(tft_blue),
	.x(tft_x), .y(tft_y),
	.color(color),
	.new_frame(tft_new_frame)
);

//instantiate the touchpad controller
touchpad_controller TOUCH(
	.cclk(cclk), .rstb(rstb), .touch_clk(touch_clk),
	.touch_busy(touch_busy),
	.data_in(touch_data_out),
	.data_out(touch_data_in),
	.touch_csb(touch_csb),
	.x(touch_x),
	.y(touch_y),
	.z(touch_z)
);

//debugging with LEDs and the switches
assign led[6:0] = PC[8:2] + 8'd1; //the current instruction number
//debugging port
assign JB = 8'b0; //feel free to connect signals here so that you can probe them


endmodule

`default_nettype wire //disable default_nettype so non-user modules work properly

