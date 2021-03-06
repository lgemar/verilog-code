`timescale 1ns / 1ps
`default_nettype none

`define TOUCH_CLK_DIV_COUNT 100

// Maybe useful defines
`define TOUCH_X_ADJ_MIN 12'h090
`define TOUCH_X_POST_ADJ_MAX 12'h745

`define TOUCH_Y_ADJ_MIN 12'h060
`define TOUCH_Y_POST_ADJ_MAX 12'h6F0
`define INPUT_MESSAGE_SZ 12
`define OUTPUT_MESSAGE_SZ 8

// Important!  The data_in pin here corresponds to the spi_data_out pin on the lab handout.
// Likewise, the spi_data_in pin on the handout corresponds to the data_out port here!
// The spi_* signals are named from the point of view of the touchpad itself, whereas the signals
// here are named from the point of view of the module. That is to say, data_out here is what the module
// is sending, data_in is what the module is receiving.

module touchpad_controller(
	input wire cclk, rstb,
	input wire touch_busy,data_in,
	output reg touch_clk, data_out,
	output reg touch_csb,
	output reg [`INPUT_MESSAGE_SZ-1:0] x,y,z
);

reg [31:0] clk_div_counter;
reg [31:0] repetition_count;
reg [31:0] progress_count; // Tracks the progress of a transaction

/** Transaction signals for a single transaction */
wire sending; // True if a message is being sent to the touchpad
wire receiving; // True if a message is being received from the touchpad
wire active;
wire transaction_end; // Equal to one when a transaction has ended after 20 clks
assign sending = (progress_count >= 0) && (progress_count < 8);
assign receiving = (progress_count >= 9) && (progress_count < 21);
assign active = sending | receiving;
assign transaction_end = (progress_count == 24); // True if transaction is over

/** Repetition signals and channel selection */
wire switch_channel;
assign switch_channel = (repetition_count == 15);

/** Touchpad selector message */
/** Selects channel: (x is 10, y is 00, and z is 01) */
reg [1:0] channel_selector; // Selects between channels x, y, z
wire [`OUTPUT_MESSAGE_SZ-1:0] selector_message;
reg [`OUTPUT_MESSAGE_SZ-1:0] data_out_mask;
assign selector_message[0] = 1'b1;
assign selector_message[2:1] = channel_selector;
assign selector_message[3] = 1'b1;
assign selector_message[7:4] = 4'b0;

/** Touchpad data inputs */
reg [`INPUT_MESSAGE_SZ-1:0] input_message;
reg [`INPUT_MESSAGE_SZ-1:0] data_in_mask;

`define X_SELECT 2'b10
`define Y_SELECT 2'b00
`define Z_SELECT 2'b01

always @(posedge cclk) begin
	if(~rstb) begin
		clk_div_counter <= 0;
		data_out_mask <= 8'b0000_0001;
		input_message <= 12'b0000_0000_0000;
		data_in_mask <= 12'b1000_0000_0000;
        data_out <= 0;
        touch_clk <= 0;
		progress_count <= 0;
		channel_selector <= `X_SELECT;
		repetition_count <= 0;
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
				/* PUT ALL CODE HERE FOR NEGATIVE EDGE FSM LOGIC! */
                if(active) begin
                    if(sending) begin
                        // do something with data_out
                        data_out <= |(selector_message & data_out_mask);
                        data_out_mask <= (data_out_mask << 1);
                    end
                end

				if (transaction_end & repetition_count != 14) begin
					data_out_mask <= 8'b0000_0001;
					data_in_mask <= 12'b1000_0000_0000;
					input_message <= 12'b0000_0000_0000;
					repetition_count <= repetition_count + 1;
					progress_count <= 0;
				end
				else if (transaction_end) begin
					repetition_count <= repetition_count + 1;
				end

                if(switch_channel) begin
                    case (channel_selector)
                        `X_SELECT: begin
                            channel_selector <= `Y_SELECT;
                            //x <= 1000;
                            x <= input_message;
                        end
                        `Y_SELECT: begin
                            channel_selector <= `Z_SELECT;
                            //y <= 1000;
                            y <= input_message;
                        end
                        `Z_SELECT: begin
                            channel_selector <= `X_SELECT;
                            //z <= 12'b111000000000;
                            z <= input_message;
                        end
                    endcase
                    repetition_count <= 0;
                end
				progress_count <= progress_count + 1;
			end
			else begin 
				// positive edge logic
				if (receiving) begin
					// do something with data_in
					if(data_in) begin
						input_message <= input_message | data_in_mask;
					end
					data_in_mask <= (data_in_mask >> 1);
				end
			end
		end
	end
end

endmodule
`default_nettype wire
