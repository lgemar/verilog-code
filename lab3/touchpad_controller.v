`timescale 1ns / 1ps
`default_nettype none

`define TOUCH_CLK_DIV_COUNT 25

// Maybe useful defines
`define TOUCH_X_ADJ_MIN 12'h090
`define TOUCH_X_POST_ADJ_MAX 12'h745

`define TOUCH_Y_ADJ_MIN 12'h060
`define TOUCH_Y_POST_ADJ_MAX 12'h6F0

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
	output reg [8:0] x,y,z
);

reg touch_csb, data_out, touch_clk; // not sure if I need these declarations
reg [4:0] clk_div_counter;
reg [3:0] repetition_count;
reg [4:0] progress_count; // Tracks the progress of a transaction

/** Transaction signals for a single transaction */
wire sending; // True if a message is being sent to the touchpad
wire receiving; // True if a message is being received from the touchpad
wire active;
wire transaction_end; // Equal to one when a transaction has ended after 20 clks
assign sending = (progress_count >= 0) && (progress_count < 8);
assign receiving = (progress_count >= 8) && (progress_count < 20);
assign active = sending | receiving;
assign transaction_end = (progress_count == 20); // True if transaction is over

/** Repetition signals and channel selection */
wire switch_channel;
assign switch_channel = (repetition_count == 15);

/** Touchpad selector message */
/** Selects channel: (x is 10, y is 00, and z is 01) */
reg [1:0] channel_selector; // Selects between channels x, y, z
wire [7:0] selector_message;
reg [7:0] data_out_mask;
assign selector_message[0] = 1'b1;
assign selector_message[2:1] = channel_selector;
assign selector_message[3] = 1'b1;
assign selector_message[7:4] = 4'b0;

/** Touchpad data inputs */
reg [11:0] input_message;
reg [11:0] data_in_mask;

`define X_SELECT 3'b10
`define Y_SELECT 3'b00
`define Z_SELECT 3'b01

always @(posedge cclk) begin
	if(~rstb) begin
		clk_div_counter <= 0;
		data_out_mask <= 8'b0000_0001;
		input_message <= 12'b0000_0000_0000;
		data_in_mask <= 12'b1000_0000_0000;
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
				/** Pseudocode: 
				 *  if(active) 
						if(sending)
							// do something with data_out
							data_out <= selector_message & data_out_mask;
							data_out_mask <= (data_out_mask << 1);
						elif(receiving)
							// do something with data_in
							if(data_in)
								input_message <= input_message | data_in_mask;
							data_in_mask <= (data_in_mask >> 1);
						progress_count <= progress_count + 1;
					elif(transaction_end)
						data_out_mask <= 8'b0000_0001;
						data_in_mask <= 12'b1000_0000_0000;
				    	++repetition_count;

					if(switch_channel)
						case X: 
							// do something with x output
							channel_selector <= Y;
						case Y: 
							// do something with y output
							channel_selector <= Z;
						case Z: 
							// do something with z output
							channel_selector <= X;
						repetition_count <= 0;
				*/
			end
		end
	end
end

endmodule
`default_nettype wire
