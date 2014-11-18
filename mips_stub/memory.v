`timescale 1ns/1ps

//`define SYNTHESIS //uncomment this line when you are ready for synthesis

module memory(
	cpu_clk, cpu_mem_addr, cpu_mem_wr_ena, cpu_mem_wr_data, cpu_mem_rd_data,
	gpu_clk, gpu_mem_addr, gpu_mem_wr_ena, gpu_mem_wr_data, gpu_mem_rd_data
);
	parameter in_file = "in.machine";
	parameter out_file = "out.machine";

	//cpu memory interface
	input cpu_clk, cpu_mem_wr_ena;
	input [31:0] cpu_mem_addr, cpu_mem_wr_data;
	output [31:0] cpu_mem_rd_data;
	//gpu memory interface
	input gpu_clk, gpu_mem_wr_ena;
	input [31:0] gpu_mem_addr, gpu_mem_wr_data;
	output [31:0] gpu_mem_rd_data;
	
	wire [11:0] physical_address;
	assign physical_address = cpu_mem_addr[13:2];  //toss out the higher address bits (you can easily add more address bits for a different memory size by changing this line)

// do not modify anything under this line (except the filename in the $readmemh command)
// no seriously, people did it last year and it was very hard to debug.  Just don't modify anything
`ifndef SYNTHESIS  
	reg [31:0] physical_memory [0:4095];
	integer ii, file;
	reg [31:0] read_data_reg;
	assign cpu_mem_rd_data = read_data_reg;
	//this initial block is only used to MODEL memories - do not use this elsewhere in your design!
	initial begin
		//edit the included initial_memory.memh file to try different machine code
		//zeroeverything
		for(ii = 0; ii < 4096; ii = ii + 1) begin
			physical_memory[ii] = 32'd0;
		end
		//read the file into the physical memory
		$readmemh(in_file, physical_memory);
	end
	
	always @(posedge cpu_clk) begin
		if(cpu_mem_wr_ena) begin
			physical_memory[physical_address] <= cpu_mem_wr_data;
			read_data_reg <= cpu_mem_wr_data; //modeling a write first ram (which is what the FPGA ram is)
		end
		else begin
			read_data_reg <= physical_memory[physical_address];
		end
	end
	
	task dump;
		begin
			file = $fopen(out_file,"w");
			for(ii = 0; ii < 4096; ii = ii + 1) begin
				$fwrite(file, "%h\n", physical_memory[ii]);
			end
			$fclose(file);
		end
	endtask
	
`else
	fpga_ram FPGA_RAM0 (
		.clka(cpu_clk), // input clka
		.wea(cpu_mem_wr_ena), // input [0 : 0] wea
		.addra(cpu_mem_addr), // input [11 : 0] addra
		.dina(cpu_mem_wr_data), // input [31 : 0] dina
		.douta(cpu_mem_rd_data), // output [31 : 0] douta
		.clkb(gpu_clk), // input clkb
		.web(gpu_mem_wr_ena), // input [0 : 0] web
		.addrb(gpu_mem_addr), // input [11 : 0] addrb
		.dinb(gpu_mem_wr_data), // input [31 : 0] dinb
		.doutb(gpu_mem_rd_data) // output [31 : 0] doutb
	);
`endif
endmodule
