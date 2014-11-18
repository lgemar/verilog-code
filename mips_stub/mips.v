`timescale 1ns/1ps

`default_nettype none

module mips(clk, rstb, mem_wr_data, mem_addr, mem_rd_data, mem_wr_ena, PC);

	input wire clk, rstb;
	input wire [31:0] mem_rd_data;  // Instuction & MDR
	output reg mem_wr_ena;			// reading or writing from memory
	output wire [31:0] mem_wr_data, mem_addr;	// data to write to memory at mem_addr
	output reg [31:0] PC;			// new PC
		
	// MIPS outputs assignment, PC will be assigned in FSM
	assign mem_addr = ctrl_iord ? alu_out : PC;
	assign mem_wr_data = reg_b;
	assign mem_wr_ena = ctrl_memwr;

	/** SubModules **/

	// Control Unit out wires
	wire ctrl_pcwr, ctrl_iord, ctrl_memrd, ctrl_memwr, 
		 ctrl_memtoreg, ctrl_iregwr, ctrl_regwr;
	wire [1:0] ctrl_pcwrcond, ctrl_pcsrc, ctrl_alusrca, ctrl_alusrcb, ctrl_regdst;
	wire [2:0] ctrl_aluop;
	wire [3:0] ctrl_state;
	
	control_unit CONTROL (
		.cclk(clk),
		.rstb(rstb),
		.state(ctrl_state),
		.inst(inst_reg),

		.pc_write(ctrl_pcwr),
		.i_or_d(ctrl_iord),
		.mem_read(ctrl_memrd),
		.mem_write(ctrl_memwr),
		.mem_to_reg(ctrl_memtoreg),
		.ir_write(ctrl_iregwr),
		.reg_write(ctrl_regrw),

		.alu_src_a(ctrl_alusrca),
		.alu_src_b(ctrl_alusrcb),
		.regdst(ctrl_regdst),
		.pc_source(ctrl_pcsrc),
		.pc_wr_cond(ctrl_pcwrcond),
		.alu_op(ctrl_aluop),
		// output
		.next_state(ctrl_state)
	)

	// Instantiate ALU control with inputs and outputs
	alu_control ALU_CONTROL (
		.alu_op(ctrl_aluop),
		.opcode(inst_reg[31:26]),
		.func(inst_reg[5:0]),

		.alu_ctrl(ALUControl)
	)

	// Instantiate ALU component with inputs and outputs
	// TODO MUX logic for inputs
	// ALU inputs
	reg [3:0] ALUControl;	// output from the ALU_CONTROL TODO can it be a reg
	reg [31:0] SrcA, SrcB;	// output from two MUX
	// ALU outputs
	wire [31:0] ALUResult;
	wire Zero;
	behavioural_alu ALU (
		.X(SrcA), 
		.Y(SrcB), 
		.op_code(ALUControl), 

		.Z(ALUResult), 
		.zero(Zero)
	);

	// Instantiate register File
	// TODO MUX logic for inputs
	// Register Inputs
	// clk, rstb are already instantiated
	wire [4:0] a1, a2, wr_reg;
	wire ctrl_werf;
	wire [31:0] wdrf;
	// Register Outputs
	wire [31:0] rd1, rd2;
	// Assign and initialize inputs
	assign a1 = mem_rd_data[25:21];
	register REG (
		.rst(rstb),						// reset (directly)
		.clk(clk),						// clock (directly)
		.write_ena(ctrl_werf),			// write enable RF (from Control)
		.address1(inst_reg[25:21]),		// addrA (directly from inst_reg)
		.address2(inst_reg[20:16]),		// addrB (directly from inst_reg)
		.address3(wr_reg),				// write register (from MUX)
		.write_data(wdrf),				// write data (from MUX)

		.read_data1(rd1),				// output data A (into SrcA MUX)
		.read_data2(rd2)				// output data B (into SrcB MUX)
	);

	// Instantiate sign extension unit
	wire [31:0] s_ext_out;
	sign_extender SIGN_EXTENDER (
		.in(inst_reg[15:0]),
		.out(s_ext_out)
	)

	/** FSM Logic **/
	
	// MIPS internal registers for FSM
	reg  [31:0] mem_data_reg, inst_reg, reg_a, reg_b, alu_out;
	// TODO FSM Logic
	// reg_a <= rd1
	// reg_b <= rd2
	// inst_reg <= (?) mem_rd_data
	// mem_data_reg <= mem_rd_data
	// alu_out <= ALUResult
	
	assign mem_addr = 32'h4000 + PC;
	assign mem_wr_data = 0;

	always@(posedge clk) begin
		if(~rstb) begin
			PC <= 32'h4000;
			mem_data_reg <= 32b'0;
			inst_reg <= 32b'0;
			reg_a <= 32b'0;
			reg_b <= 32b'0;
			alu_out <= 32b'0;
			mem_wr_ena <= 0;	// TODO do we need it here?
		end
		else begin
			PC <= PC + 4; // test PC interaction with the memory read address
		end
	end

endmodule

`default_nettype wire
