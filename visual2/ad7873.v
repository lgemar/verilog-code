`default_nettype none
`timescale 1ns/1ps

`ifndef AD7873_DEFINES
`define AD7873_DEFINES

`define AD7873_MODE_8bit  1'b1
`define AD7873_MODE_12bit 1'b0

`define AD7873_PD_ALL_ON 2'b11 //adc and reference always on
`define AD7873_PD_REF_ON 2'b10 //keeps ref on, adc only on during conversions
`define AD7873_PD_ADC_ON 2'b10 //keeps adc on, reference stays off in odd ways
`define AD7873_PD_OFF    2'b00 //power downs whole chip

`define AD7873_S_RD_IDLE    1'b0
`define AD7873_S_RD_ACTIVE  1'b0
`define AD7873_S_WR         1'b1

`define AD7873_RD_START  6
`define AD7873_RD_END    0

`define AD7873_WR_START  13
`define AD7873_WR_END    0

`endif
/*
	NOTE: THIS CODE WAS NOT WRITTEN TO BE SYNTHESIZED
*/

/* AD7873 control register
	7: start bit
	6: A2
	5: A1
	5: A0
	4: mode (0 -> 12 bits, 1 -> 8 bits)
	5: ser_dfrb (single ended or differential mode)
	6: PD1
	7: PD0
*/

/* test:
	-that csb performs properly in an asynchronous manner
	-that the outputs are z when appropriate to make debugging with this module useful
*/

module ad7873(
	dclk, dout, din, csb, busy
);

input wire dclk, din, csb;
output reg dout, busy;

reg [6:0] control = 0;
reg signed [11:0] output_buffer_clean, output_buffer;

parameter NOISE = 0;
reg signed [11:0] noise = 0;

//csb asynchronous logic
reg active = 0;
always @(csb) begin
	if(csb) begin //positive edge
		active = 0;
	end
	else begin //negative edge - turns everything on
		active = 1;
	end
end


//output buffer logic
always @(*) begin
	case(control)
		7'b101_0011 : output_buffer_clean = 12'd370;
		7'b001_0011 : output_buffer_clean = 12'd192;
		7'b011_0011 : output_buffer_clean = 12'd500;
		default     : output_buffer_clean = 12'bzzzz_zzzz_zzzz;
	endcase
	output_buffer = output_buffer_clean + noise;
end
//noise generator
always @(posedge write_state) begin
	noise <= (NOISE) ? $random >>> 28: 0; //$random returns a 32 bit integer, bringing it down here to a reasonable level
end

//state
reg read_state = 0;
reg read_offline = 0;
reg write_state = 0;
reg [7:0] read_counter = 0;
reg [7:0] write_counter = 0;

//control register is loaded on the positive edge of the clock
always @(dclk) begin
	if(~active) begin
		read_state <= 0;
		read_offline <= 0;
		read_counter <= `AD7873_RD_START;
		write_state <= 0;
		write_counter <= `AD7873_WR_START;
		busy <= 0;
	end
	else begin
		if(dclk) begin //positive edge logice
			if(~read_state) begin //read has not started
				if(din & ~read_offline) begin // din has to be 1 (start bit) for a read to start.  cannot start till the conversion is sufficiently returned...
					read_counter <= `AD7873_RD_START;
					read_state <= 1;
				end
			end
			else begin //in an active read
				control[read_counter] <= din;
				if(read_counter > `AD7873_RD_END) begin
					read_counter <= read_counter -1;
				end
				else begin
					read_state <= 0;
					write_state <= 1;
					read_offline <= 1;
					busy <= 1'b1;
				end
				
			end
		end
		else begin //negative edge logic
			if(~write_state) begin
				write_counter <= `AD7873_WR_START;
			end
			else begin
				if(busy) begin
					write_counter <= write_counter - 1;
					if(write_counter < `AD7873_WR_START) begin
						busy <= 0;
					end
				end
				else begin
					busy <= 0;
					if(write_counter > `AD7873_WR_END) begin
						write_counter <= write_counter -1;
					end
					else begin
						write_state <= 0;
					end
					if(write_counter == 6) begin
						read_offline <= 0;
					end
				end
			end
		end
	end
end

//dout logic (combinational)
always @(*) begin
	if(~active | busy) begin
		dout = 1'bz;
	end
	else begin
		if(write_state) begin
			if( (write_counter >= 12'd0) && (write_counter <= 12'd11)) begin
				dout = output_buffer[write_counter]; 
			end
			else begin
				dout = 1'b0;
			end
		end
		else begin
			dout = 1'b0;
		end
	end
end

endmodule

`default_nettype wire
