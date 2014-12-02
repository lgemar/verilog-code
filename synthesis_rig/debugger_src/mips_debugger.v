`default_nettype none

`define CHAR_ROM_LENGTH 1520
`define CHAR_LENGTH     95
`define CHAR_WIDTH      7

module mips_debugger(clk, rstb, PC, full_register_file, tft_x, tft_y, tft_new_frame, color, mem_rd_addr, mem_rd_data, mem_wr_ena, mem_wr_addr, mem_wr_data, ram_colors, core_ena);
//mips debugger
input wire clk, rstb, tft_new_frame, ram_colors, core_ena;
input wire [31:0] PC;
input wire [32*32-1:0] full_register_file;
input wire [9:0] tft_x;
input wire [8:0] tft_y;
output reg [23:0] color;
input wire [31:0] mem_rd_data;
output reg [31:0] mem_rd_addr;
output reg [31:0] mem_wr_addr, mem_wr_data;
output reg        mem_wr_ena;
reg [23:0] color_fg, color_bg;


reg [7:0] CHAR_ROM[0:`CHAR_ROM_LENGTH-1];
reg [10:0] char_rom_addr;
reg [9:0] char_rom_x_offset, char_rom_rel_x;
reg [8:0] char_rom_y_offset, char_rom_rel_y;
wire [`CHAR_WIDTH-1:0] current_char;
initial begin
	$readmemh("char_rom_8x16.memh", CHAR_ROM, 0, `CHAR_ROM_LENGTH-1);
end
wire [7:0] char_rom_data;
assign char_rom_data = CHAR_ROM[char_rom_addr];

//offsets in pixels of the different debugger regions (inclusive min/max in pixels)
`define RFILE0_X_MIN 10'd0
`define RFILE0_X_MAX 10'd63
`define RFILE0_Y_MIN  9'd0
`define RFILE0_Y_MAX  9'd255

`define RFILE1_X_MIN 10'd72
`define RFILE1_X_MAX 10'd135
`define RFILE1_Y_MIN  9'd000
`define RFILE1_Y_MAX  9'd255

`define CELLS_X_MIN 10'd224
`define CELLS_X_MAX 10'd479
`define CELLS_Y_MIN  9'd0
`define CELLS_Y_MAX  9'd255

`define PC_X_MIN 10'd0
`define PC_X_MAX 10'd63
`define PC_Y_MIN  9'd256
`define PC_Y_MAX  9'd271

`define LINE_X_MIN 10'd72
`define LINE_X_MAX 10'd135
`define LINE_Y_MIN  9'd256
`define LINE_Y_MAX  9'd271

wire in_rfile0, in_rfile1, in_PC, in_line, in_cells;
reg [3:0] current_nibble;
reg [4:0] current_register;
reg [31:0] current_data;
nibble_to_char CHARACTER_GENERATOR (.nibble(current_nibble), .char(current_char));
assign in_rfile0 = ( tft_x >= `RFILE0_X_MIN ) && (tft_x <= `RFILE0_X_MAX ) && ( tft_y >= `RFILE0_Y_MIN ) && ( tft_y <= `RFILE0_Y_MAX );
assign in_rfile1 = ( tft_x >= `RFILE1_X_MIN ) && (tft_x <= `RFILE1_X_MAX ) && ( tft_y >= `RFILE1_Y_MIN ) && ( tft_y <= `RFILE1_Y_MAX );
assign in_PC =     ( tft_x >= `PC_X_MIN     ) && (tft_x <= `PC_X_MAX     ) && ( tft_y >= `PC_Y_MIN     ) && ( tft_y <= `PC_Y_MAX     );
assign in_line =   ( tft_x >= `LINE_X_MIN   ) && (tft_x <= `LINE_X_MAX   ) && ( tft_y >= `LINE_Y_MIN   ) && ( tft_y <= `LINE_Y_MAX   );
assign in_cells =  ( tft_x >= `CELLS_X_MIN  ) && (tft_x <= `CELLS_X_MAX  ) && ( tft_y >= `CELLS_Y_MIN  ) && ( tft_y <= `CELLS_Y_MAX  );
reg [1023:0] slice_start;

wire [2:0] nibble_index, rom_data_index;

assign nibble_index = char_rom_rel_x[5:3];
assign rom_data_index = 3'd7 - char_rom_rel_x[2:0];

always @(*) begin
	char_rom_rel_x = tft_x - char_rom_x_offset;
	char_rom_rel_y = tft_y - char_rom_y_offset;
	char_rom_addr = {current_char , char_rom_rel_y[3:0]};
	current_register = in_rfile1 ?  ((char_rom_rel_y >> 4) + 5'd16) : (char_rom_rel_y >> 4);
	
	case ({in_rfile0, in_rfile1, in_PC, in_line, in_cells})
		5'b10000 : char_rom_x_offset = `RFILE0_X_MIN;
		5'b01000 : char_rom_x_offset = `RFILE1_X_MIN;
		5'b00100 : char_rom_x_offset = `PC_X_MIN    ;
		5'b00010 : char_rom_x_offset = `LINE_X_MIN  ;
		5'b00001 : char_rom_x_offset = `CELLS_X_MIN ;
		default  : char_rom_x_offset = 0            ;
	endcase
	case ({in_rfile0, in_rfile1, in_PC, in_line, in_cells})
		5'b10000 : char_rom_y_offset = `RFILE0_Y_MIN;
		5'b01000 : char_rom_y_offset = `RFILE1_Y_MIN;
		5'b00100 : char_rom_y_offset = `PC_Y_MIN;
		5'b00010 : char_rom_y_offset = `LINE_Y_MIN;
		5'b00001 : char_rom_y_offset = `CELLS_Y_MIN;
		default  : char_rom_y_offset = 0;
	endcase
	
	//find the nibble currently being displayed 
	case(nibble_index)
		3'd0 : current_nibble = current_data[31:28];
		3'd1 : current_nibble = current_data[27:24];
		3'd2 : current_nibble = current_data[23:20];
		3'd3 : current_nibble = current_data[19:16];
		3'd4 : current_nibble = current_data[15:12];
		3'd5 : current_nibble = current_data[11: 8];
		3'd6 : current_nibble = current_data[ 7: 4];
		3'd7 : current_nibble = current_data[ 3: 0];
	endcase
	
	/*
		want rel_y/16 to determine the current register (add 16 if we are in rfile1 (the second bank of 16 registers))
		then we want to get the 32 bits indexed by that register in full_register_file.  With 32 bits per register, that gives us
		the slice [32*(current_register+1)-1:32*current_register]
		
		that gives us
		(((rel_y >> 4) + 1)<<5)-1 : (rel_y >> 4)
	*/
	
	if (in_rfile0 | in_rfile1) begin
		case(current_register)
			//print "\n".join(["5'd%02d : full_register_file[%3d:%3d];"%(x, 32*(x+1)-1, 32*x) for x in range(32)]) 
			5'd00 : current_data = full_register_file[ 31:  0];
			5'd01 : current_data = full_register_file[ 63: 32];
			5'd02 : current_data = full_register_file[ 95: 64];
			5'd03 : current_data = full_register_file[127: 96];
			5'd04 : current_data = full_register_file[159:128];
			5'd05 : current_data = full_register_file[191:160];
			5'd06 : current_data = full_register_file[223:192];
			5'd07 : current_data = full_register_file[255:224];
			5'd08 : current_data = full_register_file[287:256];
			5'd09 : current_data = full_register_file[319:288];
			5'd10 : current_data = full_register_file[351:320];
			5'd11 : current_data = full_register_file[383:352];
			5'd12 : current_data = full_register_file[415:384];
			5'd13 : current_data = full_register_file[447:416];
			5'd14 : current_data = full_register_file[479:448];
			5'd15 : current_data = full_register_file[511:480];
			5'd16 : current_data = full_register_file[543:512];
			5'd17 : current_data = full_register_file[575:544];
			5'd18 : current_data = full_register_file[607:576];
			5'd19 : current_data = full_register_file[639:608];
			5'd20 : current_data = full_register_file[671:640];
			5'd21 : current_data = full_register_file[703:672];
			5'd22 : current_data = full_register_file[735:704];
			5'd23 : current_data = full_register_file[767:736];
			5'd24 : current_data = full_register_file[799:768];
			5'd25 : current_data = full_register_file[831:800];
			5'd26 : current_data = full_register_file[863:832];
			5'd27 : current_data = full_register_file[895:864];
			5'd28 : current_data = full_register_file[927:896];
			5'd29 : current_data = full_register_file[959:928];
			5'd30 : current_data = full_register_file[991:960];
			5'd31 : current_data = full_register_file[1023:992];
		endcase
		color_fg = 24'hFF_FF_FF;
		color_bg = 24'h04_04_04;
		color = char_rom_data[rom_data_index] ? color_fg : color_bg;
	end
	else if (in_PC) begin
		current_data = PC;
		color_fg = 24'hFF_FF_FF;
		color_bg = 24'h04_04_04;
		color = char_rom_data[rom_data_index] ? color_fg : color_bg;
	end
	else if (in_line) begin
		current_data = {2'd00,PC[31:2]} + 32'd1; //compute current line number
		color = char_rom_data[rom_data_index] ? color_fg : color_bg;
	end
	else if (in_cells) begin
		//TODO put in cell memory address/data logic here
		current_data = 0;
		if( (char_rom_rel_x[3:0]===5'd0) | (char_rom_rel_y[3:0]===5'd0) ) begin
			color = 24'h00_00_00;
		end
		else begin
			if(ram_colors) begin
				color = mem_rd_data[23:0];
			end
			else begin
				color= mem_rd_data[0] ? 24'hff_00_00 : 24'h00_00_ff;
			end
		end
	end
	else begin
		current_data = 0;
		color_fg = 24'h01_01_01;
		color_bg = 24'h01_01_01;
		color = 24'h00_00_0f;
	end
	
	
	if(in_cells) begin
		mem_rd_addr = {22'h0, char_rom_rel_y[7:4], char_rom_rel_x[7:4], 2'b0};
	end
	else begin
		mem_rd_addr = 0;
	end
	
	if(tft_new_frame) begin
		mem_wr_ena = 1;
		mem_wr_addr = 32'd2048;
	end
	else begin
		mem_wr_ena = 0;
		mem_wr_addr = 32'd0;
		
	end
end

always @(posedge clk) begin
	if(~rstb) begin
		mem_wr_data <= 0;
	end
	else begin
		if(tft_new_frame) begin
			mem_wr_data <= mem_wr_data + 1;
		end
	end
end

endmodule

`default_nettype wire 
