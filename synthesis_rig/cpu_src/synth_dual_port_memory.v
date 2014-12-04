`default_nettype none
`timescale 1ns/1ps

`include "mips_memory_space_defines.v"
`define SYNTHESIS

/*
	this memory is for a more von nuemann approach to CPU design that is made to synthesize appropriately
	the instruction and data memory are still split up to allow for different address spaces
		0x4000_0000 is the start of memory address space
		0x0000_0000 is the start of data address space
	it is von nuemann in the sense that the instruction data can be overwritten.
	
	it has two buses for use in pipeline architectures (so that you can read and write two separate addresses at the same time) or for debugging or IO
*/

module synth_dual_port_memory( 
	clk, rstb, error,
	//bus 0
	wr_ena0, addr0, din0, dout0,
	//bus 1
	wr_ena1, addr1, din1, dout1
);

parameter N = 32;  //bus  width
parameter I_LENGTH = 512;
parameter I_WIDTH  = 9;

parameter D_LENGTH = 1024;
parameter D_WIDTH  = 10;

input wire clk, rstb;
output reg error = 0;

input wire wr_ena0, wr_ena1;
input wire [N-1:0] addr0, din0, addr1, din1;
output reg [N-1:0] dout0, dout1;

//memories
reg  [N-1:0] IMEM [I_LENGTH-1:0];
reg  [N-1:0] DMEM [D_LENGTH-1:0];

//physical addresses
wire [I_WIDTH-1:0] phy_i_addr0, phy_i_addr1;
wire [D_WIDTH-1:0] phy_d_addr0, phy_d_addr1;
assign phy_i_addr0 = addr0[I_WIDTH+1:2];
assign phy_d_addr0 = addr0[D_WIDTH+1:2];
assign phy_i_addr1 = addr1[I_WIDTH+1:2];
assign phy_d_addr1 = addr1[D_WIDTH+1:2];

wire i0, i1, d0, d1, wr_i_ena0, wr_d_ena0, wr_i_ena1, wr_d_ena1;
assign i0 = addr0[31:20] === `I_START_ADDRESS;
assign i1 = addr1[31:20] === `I_START_ADDRESS;
assign d0 = ~i0;
assign d1 = ~i1;
assign wr_i_ena0 = i0 & wr_ena0;
assign wr_d_ena0 = d0 & wr_ena0;
assign wr_i_ena1 = i1 & wr_ena1;
assign wr_d_ena1 = d1 & wr_ena1;
reg [N-1:0] i_dout0, i_dout1, d_dout0, d_dout1;
reg last_i0, last_i1;

//instruction memory and data memory coded separately to allow for easier synthesis

//instruction memory
always @(posedge clk) begin
	if(wr_i_ena0) begin
		IMEM[phy_i_addr0] <= din0;
	end
	i_dout0 <= IMEM[phy_i_addr0];
end
always @(posedge clk) begin
	if(wr_i_ena1) begin
		IMEM[phy_i_addr1] <= din1;
	end
	i_dout1 <= IMEM[phy_i_addr1];
end

//data memory
always @(posedge clk) begin
	if(wr_d_ena0) begin
		DMEM[phy_d_addr0] <= din0;
	end
	d_dout0 <= DMEM[phy_d_addr0];
end
always @(posedge clk) begin
	if(wr_d_ena1) begin
		DMEM[phy_d_addr1] <= din1;
	end
	d_dout1 <= DMEM[phy_d_addr1];
end

always @(posedge clk) begin
	last_i0 <= i0;
	last_i1 <= i1;
end

always @(*) begin
	if(last_i0) begin
		dout0 = i_dout0;
	end
	else begin
		dout0 = d_dout0;
	end
	if(last_i1) begin
		dout1 = i_dout1;
	end
	else begin
		dout1 = d_dout1;
	end
end

`ifndef SYNTHESIS
reg [8*100:0] INIT_INST;
reg [8*100:0] INIT_DATA;
initial begin
	if(!$value$plusargs("INIT_INST=%s", INIT_INST)) begin
		$display("no instruction file was supplied with +INIT_INST, quitting.");
		$finish;
	end	
	if(!$value$plusargs("INIT_DATA=%s", INIT_DATA)) begin
		$display("no data file was supplied, using tests/zero.memh");
		INIT_DATA = "d_synth.memh";
	end
	$display("initializing %m's instruction memory from '%s' and data memory from '%s'", INIT_INST, INIT_DATA);

	$readmemh(INIT_INST, IMEM, 0, I_LENGTH-1);
	$readmemh(INIT_DATA, DMEM, 0, D_LENGTH-1);
end
`else
initial begin
	$readmemh("i_synth.memh", IMEM, 0, I_LENGTH-1);
	$readmemh("d_synth.memh", DMEM, 0, D_LENGTH-1);
end
`endif

endmodule

`default_nettype wire

