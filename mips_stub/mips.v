`timescale 1ns/1ps

`default_nettype none

module mips(clk, rstb, mem_wr_data, mem_addr, mem_rd_data, mem_wr_ena, PC);

	input wire clk, rstb;
	input wire [31:0] mem_rd_data;  // Instuction & MDR
	output reg mem_wr_ena;			// reading or writing from memory
	output wire [31:0] mem_wr_data, mem_addr;	// data to write to memory at mem_addr
	output reg [31:0] PC;			// new PC
		
	/** SubModules **/

	// Control Unit out wires
	wire ctrl_pcwr, ctrl_iord, ctrl_memrd, ctrl_memwr, 
		 ctrl_memtoreg, ctrl_iregwr, ctrl_regwr, ctrl_extop;
	wire [1:0] ctrl_pcwrcond, ctrl_pcsrc, ctrl_alusrca, ctrl_alusrcb, ctrl_regdst;
	wire [3:0] ctrl_state;
	
	control_unit CONTROL (
		.cclk(clk),
		.rstb(rstb),
		.Instr(inst_reg),

		.IRWrite(ctrl_iregwr),
		.MemWrite(ctrl_memwr),
		.PCWrite(ctrl_pcwr),
		.RegWrite(ctrl_regrw),
		.MemtoReg(ctrl_memtoreg),
		.RegDst(ctrl_regdst),
		.IorD(ctrl_iord),
		.ALUSrcA(ctrl_alusrca),
		.PCSrc(ctrl_pcsrc),
		.ALUSrcB(ctrl_alusrcb),
		.MemRead(ctrl_memrd),
		.Branch(ctrl_pcwrcond),
		.ExtOp(ctrl_ctrl_extop),
		.ALUControl(ctrl_aluop),
		.ExtOp(ctrl_extop)
	)

	// Instantiate ALU component with inputs and outputs
	// ALU inputs
	reg [3:0] ALUControl;	// output from the ALU_CONTROL
	wire [31:0] SrcA, SrcB;	// output from two MUX
	assign SrcA = ctrl_alusrca[1] ? inst_reg[10:6] : (ctrl_alusrca[0] ? reg_a : PC);
	assign SrcB = ctrl_alusrcb[2] 
				? (ctrl_alusrcb[1] ? {ext_out[29:0], 2'b0} : ext_out)
				: (ctrl_alusrcb[0] ? 32'd4 : reg_b);

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
	// Register Inputs
	// clk, rstb are already instantiated
	wire [4:0] addr1, addr2, waddr;
	wire [31:0] wdata;
	// Register Outputs
	wire [31:0] rd1, rd2;
	// Assign and initialize inputs
	assign waddr = ctrl_dst[1] ? 5'd31 : (ctrl_dst[0] ? inst_reg[15:11] : inst_reg[20:16]);
	assign wdata = ctrl_dst[1] ? PC : (ctrl_memtoreg ? mem_rd_data : ALUResult);
	
	register REG (
		.rst(rstb),						// reset (directly)
		.clk(clk),						// clock (directly)
		.address1(inst_reg[25:21]),		// addrA (directly from inst_reg)
		.address2(inst_reg[20:16]),		// addrB (directly from inst_reg)
		.address3(waddr),				// write addr (from MUX)
		.write_data(wdata),				// write data (from MUX)
		.write_ena(ctrl_regwr),			// RegWrite from Control

		.read_data1(rd1),				// output data A (into SrcA MUX)
		.read_data2(rd2)				// output data B (into SrcB MUX)
	);

	// Instantiate sign extension unit
	// Outputs
	wire [31:0] ext_out;
	sign_extender SIGN_EXTENDER (
		.in(inst_reg[15:0]),
		.zero(ctrl_extop),
		.out(ext_out)
	)

	// MIPS outputs assignment, PC will be assigned in FSM
	assign mem_addr = ctrl_iord ? alu_out : PC;
	assign mem_wr_data = reg_b;
	assign mem_wr_ena = ctrl_memwr;

	// MIPS internal registers for FSM
	reg [31:0] mem_data_reg, inst_reg, reg_a, reg_b, alu_out;

	always@(posedge clk) begin
		if(~rstb) begin
			PC <= 32'h4000;
			mem_data_reg <= 32b'0;
			inst_reg <= 32b'0;
			reg_a <= 32b'0;
			reg_b <= 32b'0;
			alu_out <= 32b'0;
		end
		else begin
			reg_a <= rd1;
			reg_b <= rd2;
			alu_out <= ALUResult;
			if (ctrl_memtoreg) mem_data_reg <= mem_rd_data;	// update MDR if MemToReg is set
			if (ctrl_iregwr) inst_reg <= mem_rd_data;
			if (ctrl_pcwr || ctrl_pcwrcond[0] & Zero || ctrl_pcwrcond[1] & ~Zero) begin
				case (ctrl_pcsrc)
					2'b00: PC <= ALUResult;
					2'b01: PC <= alu_out;
					2'b10: PC <= { PC[31:28], inst_reg[25:0], 2'b0 }; 
					// TODO: is there forth case ? Ask Avi
				endcase
			end
		end
	end

endmodule

`default_nettype wire
