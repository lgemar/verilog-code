`timescale 1ns / 1ps
`ifndef DEFAULT_NETTYPE_NONE_SET
	`default_nettype none
	`define DEFAULT_NETTYPE_NONE_SET
`endif

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:45:04 05/25/2012
// Design Name:   tft_address_generator
// Module Name:   /home/student/testing/vmodtft/test_tft_addr_gen.v
// Project Name:  vmodtft
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: tft_address_generator
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_tft_addr_gen;

	// Inputs
	reg [8:0] x;
	reg [8:0] y;
	
	wire [17:0] addr;

	// Instantiate the Unit Under Test (UUT)
	tft_address_generator uut (
		.x(x), 
		.y(y),
		.addr(addr)
	);

	initial begin
		// Initialize Inputs
		x = 0;
		y = 0;
      for(x = 0; x < 480; x = x + 1) begin
			for (y = 0; y < 272; y = y + 1) begin
				#10;
				if(addr !==  (x*272 + y)) begin
					$display("error! addr = %d,22 x = %d, y = %d", addr, x, y);
				end
			end
		end
		$display("final address = %d", addr);
		// Add stimulus here
		$finish;
	end
endmodule

