`timescale 1ns / 1ps
`ifndef DEFAULT_NETTYPE_NONE_SET
	`default_nettype none
	`define DEFAULT_NETTYPE_NONE_SET
`endif

module test_tft;
	// Inputs
	reg cclk;
	reg rstb;
	reg wr_ena;
	reg clear_screen;
	reg [9:0] wr_x;
	reg [8:0] wr_y;
	reg [8:0] wr_data;

	// Outputs
	wire tft_backlight;
	wire tft_data_ena;
	wire tft_display;
	wire tft_vdd;
	wire tft_clk;
	wire [7:0] tft_red;
	wire [7:0] tft_green;
	wire [7:0] tft_blue;
	wire [9:0] x;
	wire [8:0] y;
	wire new_frame;
	wire clear_done;

	// Instantiate the Unit Under Test (UUT)
	tft_driver uut (
		.cclk(cclk), 
		.rstb(rstb), 
		.tft_backlight(tft_backlight), 
		.tft_data_ena(tft_data_ena), 
		.tft_display(tft_display), 
		.tft_vdd(tft_vdd), 
		.tft_clk(tft_clk), 
		.tft_red(tft_red), 
		.tft_green(tft_green), 
		.tft_blue(tft_blue), 
		.wr_ena(wr_ena), 
		.clear_screen(clear_screen), 
		.wr_x(wr_x), 
		.wr_y(wr_y), 
		.wr_data(wr_data), 
		.x(x), 
		.y(y), 
		.new_frame(new_frame),
		.clear_done(clear_done)
	);
	reg [31:0] errors;
	reg [8:0] ideal_data, actual_data;
	reg [17:0] addr;
	always #5 cclk = ~cclk;
	reg [8:0] ideal_vram [0:130559];
	integer i;
	initial begin
		// Initialize Inputs
		cclk = 0;
		rstb = 0;
		wr_ena = 0;
		clear_screen = 0;
		wr_x = 0;
		wr_y = 0;
		wr_data = 0;
		errors = 0;
		addr = 0;
		ideal_data = 0;
		actual_data = 0;
		//initialize memory
		
		for(i = 0; i <= 130559; i = i + 1) begin
			ideal_vram[i] = 9'b000_111_000;
		end
      
		// reset
		repeat (5) @(posedge cclk);
		rstb = 1;
		//reset the screen
		$display("clearing screen");
		clear_screen = 1; @(posedge cclk) clear_screen = 0;
		while(~clear_done) @(posedge cclk);
		$display("done clearing screen");
		// write in a white horizontal line at y = 100
		for (wr_y = 0; wr_y <= 272; wr_y = wr_y + 1) begin
			for(wr_x = 0; wr_x <= 480; wr_x = wr_x + 1) begin
				wr_ena = 1;
				wr_data = (wr_y == 100) ? 9'b111_111_111 : 9'b000_000_000;
				addr = 480*wr_y + wr_x;
				
				ideal_vram[addr] = (wr_y == 100) ? 9'b111_111_111 : 9'b000_000_000;
				@(posedge cclk);
				if(addr == 130559) begin	
					$display("WTF! ram[%d] = %b, wr_data = %b, wr_addr = %d", addr, ideal_vram[addr], wr_data, uut.video_ram_wr_addr);
				end

				@(posedge cclk);
				
			end
		end
		wr_ena = 0;
		//wait till the next new_frame
		while(~new_frame) @(posedge tft_clk);
		while(y !== 0) @(posedge tft_clk);
		while(y < 272) begin
			if((x>=0) && (x<480)) begin
				addr = 480*y + x;
				ideal_data = ideal_vram[addr];
				actual_data = {tft_red[7:5], tft_green[7:5], tft_blue[7:5]};
				if(ideal_data !== actual_data) begin
					errors = errors + 1;
					$display("@%t, ERROR: x = %d, y = %d, vram[%d] = %b, not %b", $time, x, y, addr ,actual_data, ideal_data);
				end
			end
			@(posedge tft_clk);
		end
		
		$display("test completed with %d errors", errors);
		$finish;
	end
	always @(posedge cclk) begin
		/*if(errors > 10) begin
			$display("MAX ERRORS REACHED! QUITTING");
			$finish;
		end
		*/
	end
   
endmodule

