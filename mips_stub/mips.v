`timescale 1ns/1ps

`default_nettype none

module mips(clk, rstb, mem_wr_data, mem_addr, mem_rd_data, mem_wr_ena, PC);

	input wire clk, rstb;
	input wire [31:0] mem_rd_data;  // Instuction & MDR
	output wire mem_wr_ena;			// reading or writing from memory
	output wire [31:0] mem_wr_data, mem_addr;	// data to write to memory at mem_addr
	output reg [31:0] PC;			// new PC
		
	/** SubModules **/

	// Control Unit out wires
	wire ctrl_pcwr, ctrl_iord, ctrl_memrd, ctrl_memwr, 
		 ctrl_memtoreg, ctrl_iregwr, ctrl_regwr, ctrl_ext;
	wire [1:0] ctrl_branch, ctrl_pcsrc, ctrl_alusrca, ctrl_alusrcb, ctrl_rdst;
	wire [3:0] ctrl_state;
	wire [3:0] alu_control;	// output from the ALU_CONTROL
	
	control_unit CONTROL (
		.cclk(clk),
		.rstb(rstb),
		.Instr(inst_reg),

		//.MemRead(ctrl_memrd),
		.MemWrite(ctrl_memwr),
		.IRWrite(ctrl_iregwr),
		.PCWrite(ctrl_pcwr),
		.RegWrite(ctrl_regwr),
		.MemtoReg(ctrl_memtoreg),
		.RegDst(ctrl_rdst),
		.IorD(ctrl_iord),
		.ALUSrcA(ctrl_alusrca),
		.ALUSrcB(ctrl_alusrcb),
		.PCSrc(ctrl_pcsrc),
		.Branch(ctrl_branch),
		.ExtOp(ctrl_ext),
		.ALUControl(alu_control)
	);

	// Instantiate ALU component with inputs and outputs
	// ALU inputs
	reg [31:0] SrcA, SrcB;	// output from two MUX
	always @(*) begin
		case (ctrl_alusrca) 
			2'b00 : SrcA = PC; 
			2'b01 : SrcA = reg_a;
			2'b10 : SrcA = { 27'b0, inst_reg[10:6] };
			//2'b11 : 
		endcase
		
		case (ctrl_alusrcb) 
			2'b00: SrcB = reg_b;
			2'b01: SrcB = 32'd4;
			2'b10: SrcB = ext_out;
			2'b11: SrcB = {ext_out[29:0], 2'b0};
		endcase
	end

	// ALU outputs
	wire [31:0] ALUResult;
	wire Zero;
	behavioural_alu ALU (
		.X(SrcA), 
		.Y(SrcB), 
		.op_code(alu_control), 

		.Z(ALUResult), 
		.zero(Zero)
	);

	// Instantiate register File
	// Register Inputs
	// clk, rstb are already instantiated
	wire [4:0] addr1, addr2;
	reg [4:0] waddr;
	reg [31:0] wdata;
	// Register Outputs
	wire [31:0] rd1, rd2;
	// Assign and initialize inputs
	//assign waddr = ctrl_rdst[1] ? 5'd31 : (ctrl_rdst[0] ? inst_reg[15:11] : inst_reg[20:16]);
	//assign wdata = ctrl_rdst[1] ? PC : (ctrl_memtoreg ? mem_rd_data : ALUResult);

	always @(*) begin
		case (ctrl_rdst) 
			2'b00 : begin
					waddr = inst_reg[20:16];								
					wdata = ctrl_memtoreg ? mem_rd_data : ALUResult;
					end
			2'b01 : begin 
					waddr = inst_reg[15:11];
					wdata = ctrl_memtoreg ? mem_rd_data : ALUResult;
					end
			2'b10 : begin	// JAL
					waddr = 5'd31;
					wdata = PC + 4;
					end
			//2'b11 : impossible
		endcase
	end
	
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
	extender EXTENDER (
		.in(inst_reg[15:0]),
		.zero(ctrl_ext),
		.out(ext_out)
	);

	// MIPS outputs assignment, PC will be assigned in FSM
	assign mem_addr = ctrl_iord ? alu_out : PC;
	assign mem_wr_data = reg_b;
	assign mem_wr_ena = ctrl_memwr;

	// MIPS internal registers for FSM
	reg [31:0] mem_data_reg, inst_reg, reg_a, reg_b, alu_out;
	wire PCEn;
	assign PCEn = ctrl_pcwr || ctrl_branch[0] & Zero || ctrl_branch[1] & ~Zero;

	always@(posedge clk) begin
		if(~rstb) begin
			PC <= 32'b0;
			mem_data_reg <= 32'b0;
			inst_reg <= 32'b0;
			reg_a <= 32'b0;
			reg_b <= 32'b0;
			alu_out <= 32'b0;
		end
		else begin
			reg_a <= rd1;
			reg_b <= rd2;
			alu_out <= ALUResult;
			if (ctrl_memtoreg) mem_data_reg <= mem_rd_data;	// update MDR if MemToReg is set
			if (ctrl_iregwr) inst_reg <= mem_rd_data;
			if (PCEn) begin	// PCEnable
				case (ctrl_pcsrc)
					2'b00: PC <= ALUResult;
					2'b01: PC <= alu_out;
					2'b10: PC <= { PC[31:28], inst_reg[25:0], 2'b0 }; 
				endcase
			end
		end
	end

endmodule

`default_nettype wire
