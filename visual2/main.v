`timescale 1ns / 1ps

`default_nettype none //makes undeclared nets errors instead of automatic wires

module main(
    //default IO
    input wire unbuf_clk, rstb,
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

            //clocking signals
            wire cclk, cclk_n, tft_clk_buf, tft_clk_buf_n, clocks_locked;
            wire reset;
            assign reset = ~rstb;

            //touchpad signals
            wire [8:0] touch_x, touch_y, touch_z;
            //tft signals
            wire [9:0] tft_x;
            wire [8:0] tft_y;
            wire tft_new_frame;

            // locked_touch signal, not provided
            reg [11:0] locked_touch_x, locked_touch_y;
            wire [11:0] locked_touch_z;
            //generate all the clocks
            clock_generator CLOCK_GEN (.clk_100M_in(unbuf_clk), .CLK_100M(cclk), .CLK_100M_n(cclk_n), .CLK_9M(tft_clk_buf), .CLK_9M_n(tft_clk_buf_n), .RESET(reset), .LOCKED(clocks_locked));
            //pass the tft_clk through a DDR2 output buffer (so that it can drive external loads and so that internal loads are unaffected by large skew routing)
            ODDR2 tft_clk_fixer (.D0(1'b1), .D1(1'b0), .C0(tft_clk_buf), .C1(tft_clk_buf_n), .Q(tft_clk), .CE(1'b1));

            //debugging
            assign led = 0;
            assign JB = 8'b0; //feel free to connect signals here so that you can probe them

            //intantiate the TFT driver

            tft_driver TFT(
                .cclk(cclk),
                .rstb(rstb),
                .tft_backlight(tft_backlight),
                .tft_clk(tft_clk_buf),
                .tft_data_ena(tft_data_ena),
                .tft_display(tft_display),
                .tft_vdd(tft_vdd),
                .tft_red(tft_red),
                .frequency_division(32'd255),
                .duty_cycle(switch),
                .tft_green(tft_green),
                .tft_blue(tft_blue),
                .x(tft_x), .y(tft_y),
                .touch_x(locked_touch_x), .touch_y(locked_touch_y),
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
            assign locked_touch_z = ((touch_z >> 8) != 12'b0000_0000_0000);

            always @(negedge tft_new_frame) begin
                if (locked_touch_z) begin
                    locked_touch_x = (touch_x >> 2);
                    locked_touch_y = (touch_y >> 2);
                end
            end
            endmodule

 `default_nettype wire //disable default_nettype so non-user modules work properly
