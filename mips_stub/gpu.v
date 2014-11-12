`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:    gpu
//
//////////////////////////////////////////////////////////////////////////////////
`define FRAME_ADDRESS 31'd8192

module gpu(
	cclk,  pclk, rstb, vsync, red, green, blue, x, y, mem_addr, mem_wr_data, mem_rd_data, mem_wr_ena, PC,
	//debugging pins
	dbg0, dbg1, dbg2, dbg3, dbg4, dbg5, dbg6, dbg7, dbg8, dbg9, dbg10, dbg11, dbg12, dbg13, dbg14, dbg15, dbg16, dbg17, dbg18, dbg19, dbg20, dbg21, dbg22, dbg23, dbg24, dbg25, dbg26, dbg27, dbg28, dbg29, dbg30, dbg31
);
	//port definitions
	input wire cclk, pclk, rstb, vsync;
	output reg [7:0] red, green, blue;
	input wire [10:0] x;
	input wire [10:0] y;
	output wire [31:0] mem_addr, mem_wr_data;
	input wire [31:0] mem_rd_data, PC;
	output wire mem_wr_ena;
	input wire [31:0] dbg0, dbg1, dbg2, dbg3, dbg4, dbg5, dbg6, dbg7, dbg8, dbg9, dbg10, dbg11, dbg12, dbg13, dbg14, dbg15, dbg16, dbg17, dbg18, dbg19, dbg20, dbg21, dbg22, dbg23, dbg24, dbg25, dbg26, dbg27, dbg28, dbg29, dbg30, dbg31;
	
	wire [31:0] cell_mem_addr;
	wire in_grid, on_border, in_regfile, in_pc;
	
	//compute address of the conway cell in ram
	assign cell_mem_addr[31:12] = 0;
   assign cell_mem_addr[11] = frame_count[0];
   assign cell_mem_addr[10] = 1;
   assign cell_mem_addr[9:2] = (in_grid) ? ({y[7:4], x[7:4]}) : 8'd0;
	assign cell_mem_addr[1:0] = 2'b00;
	//select between the "frame address" and the cell address based on whether or not we are in the grid
	assign mem_addr = (in_grid) ? cell_mem_addr : `FRAME_ADDRESS;

	
	assign in_grid = (x < 256) && (y < 256);//compute whether or not we are in the grid
	assign in_regfile = (x > 256) && (y < 256) && (x < 1280) ;
	assign on_border = (x[3:0] == 5'd0 ) || (y[3:0] == 5'd0 );  //note if we are in a border of a cell or not (for drawing grid lines)
	assign in_pc = (x < 256) && (y > 256) && (y < 288);
	
	
	//take care of writing the frame increment into memory once we've left the grid
	// We have to always right the next frame - this lets the code running on the cpu know that it is safe to continue
	assign mem_wr_ena = ~in_grid;
   assign mem_wr_data = frame_count + 1; 
	
	//display the contents of the register file (if it is wired up here)
	wire [11:0] regfile_x, regfile_y;
	wire [7:0] regfile_r, regfile_g, regfile_b;
	assign regfile_x = (x < 256) ? 12'hfff : (x-256); // shift the regfile right a bit
	assign regfile_y = y;
	debugging_rig REG_FILE_DEBUG(
		.clk(pclk), .rstb(rstb), .x(regfile_x), .y(regfile_y), .vsync(vsync), 
		.r(regfile_r), .g(regfile_g), .b(regfile_b),
		.in0(dbg0), .in1(dbg1),	.in2(dbg2), .in3(dbg3), .in4(dbg4), .in5(dbg5), .in6(dbg6), .in7(dbg7), .in8(dbg8), .in9(dbg9), .in10(dbg10), .in11(dbg11), .in12(dbg12), .in13(dbg13), .in14(dbg14), .in15(dbg15), .in16(dbg16), .in17(dbg17), .in18(dbg18), .in19(dbg19), .in20(dbg20), .in21(dbg21), .in22(dbg22), .in23(dbg23), .in24(dbg24), .in25(dbg25), .in26(dbg26), .in27(dbg27), .in28(dbg28), .in29(dbg29), .in30(dbg30), .in31(dbg31)
	);
	//display the program counter separately
	//rom_addr breakdown: [4 bits char select (0-F)] [5 bits current row]
	wire [2:0] byte_select;
	wire [8:0] rom_addr;
	wire [7:0] pc_r, pc_g, pc_b;
	half_byte_mux CHAR_MUX (
		.x(PC), 
		.byte_select(byte_select),
		.y(rom_addr[8:5])
	);
	assign rom_addr[4:0] = y[4:0];
	wire [31:0] rom_data;
	
	hex_font_rom FONT_ROM_PC (
		.clka(pclk), // input clka
		.addra(rom_addr), // input [8 : 0] addra
		.douta(rom_data) // output [31 : 0] douta
	);
	
	assign byte_select = x[7:5];
	assign pc_r = rom_data[x[4:0]] ? 8'hFF : 8'h0;
	assign pc_g = rom_data[x[4:0]] ? 8'hFF : 8'h0;
	assign pc_b = rom_data[x[4:0]] ? 8'hFF : 8'h0;
	
	//display the right colors in the right section of the screen
	always @(*) begin
		//base colors on grid location and whether or not we read anything this pixel
		if(in_grid) begin
			if(on_border) begin
				red = 0; green = 0; blue = 0;
			end
			else begin
				red   =  (~|mem_rd_data) ? 8'hff : 8'h00;
				green =  (~|mem_rd_data) ? 8'h00 : 8'h00;
				blue  =  (~|mem_rd_data) ? 8'h00 : 8'hff;
			end
		end
		else if (in_regfile) begin
			red   = regfile_r;
			green = regfile_g;
			blue  = regfile_b;
		end
		else if (in_pc) begin
			red = pc_r;
			green = pc_g;
			blue = pc_b;
		end
		else begin
			red = 8'hff; green = 8'hff; blue = 8'hff;
		end
	end
   
	//slow down writing the frame counter so that the animation is visible
	reg [31:0] frame_count;
	reg [31:0] frame_pacer;
	always @(posedge cclk) begin
		if(~rstb) begin
			frame_pacer <= 0;
			frame_count <= 0;
		end
		else begin
			if(frame_pacer == 32'd50_000_000) begin 
				frame_pacer <= 0;
				frame_count <= frame_count + 1;
			end
			else begin
				frame_pacer <= frame_pacer + 1;
			end
		end
	end
endmodule
`default_nettype wire
