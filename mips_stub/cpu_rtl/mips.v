`timescale 1ns/1ps

`default_nettype none

module mips(clk, rstb, mem_wr_data, mem_addr, mem_rd_data, mem_wr_ena, PC);

	input wire clk, rstb;
	input wire [31:0] mem_rd_data;             
	output reg mem_wr_ena;
	output wire [31:0] mem_wr_data, mem_addr;
	output reg [31:0] PC;
	
	/* put your code here! */

assign mem_addr = 0;
assign mem_wr_data = 0;

always@(posedge clk) begin
	if(~rstb) begin
		mem_wr_ena <= 0;
		PC <= 0;
	end
end

endmodule

`default_nettype wire
