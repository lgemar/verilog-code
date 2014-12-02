`default_nettype none
`timescale 1ns/1ps
module test_mips_debugger;

parameter N = 32; 
reg tft_new_frame;
reg clk, rstb;
wire [31:0] PC;
wire [32*32-1:0] full_register_file;
reg [9:0] tft_x;
reg [8:0] tft_y;
wire [23:0] color;
wire [31:0] mem_rd_data;
wire [31:0] mem_rd_addr;
wire rst;
assign rst = ~rstb;

//memory
wire [N-1:0] mem_rd_addr0, mem_wr_data0, mem_wr_addr1, mem_rd_addr1, mem_wr_data1, mem_addr0, mem_addr1;
wire [N-1:0] mem_rd_data0, mem_rd_data1;
wire mem_wr_ena0, mem_wr_ena1;

assign mem_addr1 = mem_wr_ena1 ? mem_wr_addr1 : mem_rd_addr1;
synth_dual_port_memory #(
	.N(32),
	.I_LENGTH(256),
	.D_LENGTH(513)
) MEMORY(
	.clk(clk),
	.rstb(rstb),
	.wr_ena0(mem_wr_ena0),
	.addr0(mem_addr0),
	.din0(mem_wr_data0),
	.dout0(mem_rd_data0),
	.wr_ena1(mem_wr_ena1),
	.addr1(mem_addr1),
	.din1(mem_wr_data1),
	.dout1(mem_rd_data1)
);

//mips core
wire single_step_mode, core_ena, single_step, single_step_active;
assign single_step_mode = 0;
assign core_ena = 1;
assign single_step = 0;
assign single_step_active = 0;

mips_multicycle_vn CORE (
	.clk(clk),
	.rst(rst),
	.ena(core_ena),
	.PC(PC),
	.mem_addr(mem_addr0),
	.mem_rd_data(mem_rd_data0),
	.mem_wr_data(mem_wr_data0),
	.mem_wr_ena(mem_wr_ena0),
	.full_register_file(full_register_file)
);

//mips debugger
mips_debugger UUT(
	.clk(clk),
	.rstb(rstb),
	.PC(PC),
	.full_register_file(full_register_file),
	.tft_x(tft_x),
	.tft_y(tft_y),
	.tft_new_frame(tft_new_frame),
	.color(color),
	.mem_rd_data(mem_rd_data1),
	.mem_rd_addr(mem_rd_addr1),
	.mem_wr_ena(mem_wr_ena1),
	.mem_wr_addr(mem_wr_addr1),
	.mem_wr_data(mem_wr_data1),
	.ram_colors(1)
);
integer NUM_CYCLES;
initial begin
//`define ICARUS
`ifdef ICARUS
	if(!$value$plusargs("NUM_CYCLES=%d", NUM_CYCLES)) begin
		$display("defaulting to 100 cycles");
		NUM_CYCLES = 100;
	end
	$dumpfile("waves/mips_debugger.vcd");
	$dumpvars(0, UUT);
	$dumpvars(0, CORE);
	$dumpvars(0, MEMORY);
`endif
	clk = 0;
	rstb = 0;
	repeat (2) @(posedge clk); rstb = 1;
	
	repeat(NUM_CYCLES) @(posedge clk);
	CORE.REGISTER_FILE.print_hex;
	$finish;
end

always #5 clk = ~clk;

initial begin
	tft_new_frame = 0;
end
always @(posedge clk) begin
	`define REALTIME
	`ifdef REALTIME
		tft_new_frame <= (tft_y == 9'd1) && (tft_x == 10'd1);
	`else
		tft_new_frame <= ~tft_new_frame;
	`endif

end

always @(posedge clk) begin
	if(~rstb) begin
		tft_x <= 0;
		tft_y <= 0;
	end
	else begin
		if(tft_x < 10'd480) begin
			tft_x <= tft_x + 1;
		end
		else begin
			tft_x <= 0;
			if(tft_y < 9'd272) begin
				tft_y <= tft_y + 1;
			end
			else begin
				tft_y <= 0;
			end
		end
	end
end


endmodule
`default_nettype wire
