`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    debugging_rig
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
`define MAX_FRAME_COUNT 15
module debugging_rig(clk, rstb, x, y, vsync, r, g, b, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, in16, in17, in18, in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31);
	input wire clk, rstb, vsync;
	input wire [31:0] in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, in16, in17, in18, in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31;
	input wire [11:0] x,y;
	output reg [7:0] r, g, b;
	
	wire [31:0] rom_data;
	wire [8:0] rom_addr;
	
	reg [31:0] frame_count;
	reg [31:0] latch0, latch1, latch2, latch3, latch4, latch5, latch6, latch7, latch8, latch9, latch10, latch11, latch12, latch13, latch14, latch15, latch16, latch17, latch18, latch19, latch20, latch21, latch22, latch23, latch24, latch25, latch26, latch27, latch28, latch29, latch30, latch31;

	//rom_addr breakdown
	//  [4 bits char select (0-F)] [5 bits current row]
	wire [2:0] byte_select;
	reg  [31:0] current_word;
	
	
	half_byte_mux CHAR_MUX (
		.x(current_word), 
		.byte_select(byte_select),
		.y(rom_addr[8:5])
	);
	assign rom_addr[4:0] = y[4:0];
	
	
	hex_font_rom ROM0 (
		.clka(clk), // input clka
		.addra(rom_addr), // input [8 : 0] addra
		.douta(rom_data) // output [31 : 0] douta
	);
	
	always @(*) begin
		case({y[7:5], x[9:8]})
			5'd0 : current_word = latch0;
			5'd1 : current_word = latch1;
			5'd2 : current_word = latch2;
			5'd3 : current_word = latch3;
			5'd4 : current_word = latch4;
			5'd5 : current_word = latch5;
			5'd6 : current_word = latch6;
			5'd7 : current_word = latch7;
			5'd8 : current_word = latch8;
			5'd9 : current_word = latch9;
			5'd10 : current_word = latch10;
			5'd11 : current_word = latch11;
			5'd12 : current_word = latch12;
			5'd13 : current_word = latch13;
			5'd14 : current_word = latch14;
			5'd15 : current_word = latch15;
			5'd16 : current_word = latch16;
			5'd17 : current_word = latch17;
			5'd18 : current_word = latch18;
			5'd19 : current_word = latch19;
			5'd20 : current_word = latch20;
			5'd21 : current_word = latch21;
			5'd22 : current_word = latch22;
			5'd23 : current_word = latch23;
			5'd24 : current_word = latch24;
			5'd25 : current_word = latch25;
			5'd26 : current_word = latch26;
			5'd27 : current_word = latch27;
			5'd28 : current_word = latch28;
			5'd29 : current_word = latch29;
			5'd30 : current_word = latch30;
			5'd31 : current_word = latch31;
		endcase
	end
	assign byte_select = x[7:5];
	
	reg [23:0] background_color;
	always @(*) begin
		case ({y[5],x[8]})
			2'b00 : background_color = 24'h00_00_80; 
			2'b01 : background_color = 24'h00_80_00; 
			2'b10 : background_color = 24'h00_80_00; 
			2'b11 : background_color = 24'h00_00_80; 
		endcase 
	end
	
	reg [11:0] last_y;
	always @(posedge clk) begin
		if(~rstb) begin
			r <= 8'd0;
			g <= 8'd0;
			b <= 8'd0;
			frame_count <= 0;
			last_y <= 0;
		end
		else begin
			last_y <= y;
			if ((y==1) && (last_y == 0)) begin
				if(frame_count == `MAX_FRAME_COUNT) begin
					frame_count <= 6'd0;
					latch0  <= in0;
					latch1  <= in1;
					latch2  <= in2;
					latch3  <= in3;
					latch4  <= in4;
					latch5  <= in5;
					latch6  <= in6;
					latch7  <= in7;
					latch8  <= in8;
					latch9  <= in9;
					latch10 <= in10;
					latch11 <= in11;
					latch12 <= in12;
					latch13 <= in13;
					latch14 <= in14;
					latch15 <= in15;
					latch16 <= in16;
					latch17 <= in17;
					latch18 <= in18;
					latch19 <= in19;
					latch20 <= in20;
					latch21 <= in21;
					latch22 <= in22;
					latch23 <= in23;
					latch24 <= in24;
					latch25 <= in25;
					latch26 <= in26;
					latch27 <= in27;
					latch28 <= in28;
					latch29 <= in29;
					latch30 <= in30;
					latch31 <= in31;
				end
				else begin
					frame_count <= frame_count + 6'd1;
				end
			end
			
			if( (x >= 0) && (x <= 32*8*4) && (y >= 0) && (y <= 32*8))begin
				r <= rom_data[x[4:0]] ? 8'hFF : background_color[23:16];
				g <= rom_data[x[4:0]] ? 8'hFF : background_color[15:8];
				b <= rom_data[x[4:0]] ? 8'hFF : background_color[7:0];
			end
			else begin
				r <= 8'h00;
				g <= 8'h00;
				b <= 8'h00;
			end
		end
	end
endmodule

`default_nettype wire

