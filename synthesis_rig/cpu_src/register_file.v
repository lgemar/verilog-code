`default_nettype none
`timescale 1ns/1ps

module register_file(clk, rst, rd_addr0, rd_addr1, wr_addr, rd_data0, rd_data1, wr_data, wr_ena, full_register_file);

parameter N = 32;
input wire clk, rst;
input wire [4:0] rd_addr0, rd_addr1, wr_addr;
output reg [N-1:0] rd_data0, rd_data1;
input wire [N-1:0] wr_data;
input wire wr_ena;

reg [31:0] regfile [31:0];

always @(posedge clk) begin
	
end


wire [31:0] reg_enas;
decoder #(5) REGISTER_DECODER (.enable(wr_ena), .encoded(wr_addr), .decoded(reg_enas));

wire signed [N-1:0] r00, r01, r02, r03, r04, r05, r06, r07, r08, r09, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31;

assign r00 = 0; //mips has the first register as all zeros
//register #(.N(N)) R00 (.clk(clk), .d(wr_data), .q(r00), .rst(rst), .ena(reg_enas[00]));
register #(.N(N)) R01 (.clk(clk), .d(wr_data), .q(r01), .rst(rst), .ena(reg_enas[01]));
register #(.N(N)) R02 (.clk(clk), .d(wr_data), .q(r02), .rst(rst), .ena(reg_enas[02]));
register #(.N(N)) R03 (.clk(clk), .d(wr_data), .q(r03), .rst(rst), .ena(reg_enas[03]));
register #(.N(N)) R04 (.clk(clk), .d(wr_data), .q(r04), .rst(rst), .ena(reg_enas[04]));
register #(.N(N)) R05 (.clk(clk), .d(wr_data), .q(r05), .rst(rst), .ena(reg_enas[05]));
register #(.N(N)) R06 (.clk(clk), .d(wr_data), .q(r06), .rst(rst), .ena(reg_enas[06]));
register #(.N(N)) R07 (.clk(clk), .d(wr_data), .q(r07), .rst(rst), .ena(reg_enas[07]));
register #(.N(N)) R08 (.clk(clk), .d(wr_data), .q(r08), .rst(rst), .ena(reg_enas[08]));
register #(.N(N)) R09 (.clk(clk), .d(wr_data), .q(r09), .rst(rst), .ena(reg_enas[09]));
register #(.N(N)) R10 (.clk(clk), .d(wr_data), .q(r10), .rst(rst), .ena(reg_enas[10]));
register #(.N(N)) R11 (.clk(clk), .d(wr_data), .q(r11), .rst(rst), .ena(reg_enas[11]));
register #(.N(N)) R12 (.clk(clk), .d(wr_data), .q(r12), .rst(rst), .ena(reg_enas[12]));
register #(.N(N)) R13 (.clk(clk), .d(wr_data), .q(r13), .rst(rst), .ena(reg_enas[13]));
register #(.N(N)) R14 (.clk(clk), .d(wr_data), .q(r14), .rst(rst), .ena(reg_enas[14]));
register #(.N(N)) R15 (.clk(clk), .d(wr_data), .q(r15), .rst(rst), .ena(reg_enas[15]));
register #(.N(N)) R16 (.clk(clk), .d(wr_data), .q(r16), .rst(rst), .ena(reg_enas[16]));
register #(.N(N)) R17 (.clk(clk), .d(wr_data), .q(r17), .rst(rst), .ena(reg_enas[17]));
register #(.N(N)) R18 (.clk(clk), .d(wr_data), .q(r18), .rst(rst), .ena(reg_enas[18]));
register #(.N(N)) R19 (.clk(clk), .d(wr_data), .q(r19), .rst(rst), .ena(reg_enas[19]));
register #(.N(N)) R20 (.clk(clk), .d(wr_data), .q(r20), .rst(rst), .ena(reg_enas[20]));
register #(.N(N)) R21 (.clk(clk), .d(wr_data), .q(r21), .rst(rst), .ena(reg_enas[21]));
register #(.N(N)) R22 (.clk(clk), .d(wr_data), .q(r22), .rst(rst), .ena(reg_enas[22]));
register #(.N(N)) R23 (.clk(clk), .d(wr_data), .q(r23), .rst(rst), .ena(reg_enas[23]));
register #(.N(N)) R24 (.clk(clk), .d(wr_data), .q(r24), .rst(rst), .ena(reg_enas[24]));
register #(.N(N)) R25 (.clk(clk), .d(wr_data), .q(r25), .rst(rst), .ena(reg_enas[25]));
register #(.N(N)) R26 (.clk(clk), .d(wr_data), .q(r26), .rst(rst), .ena(reg_enas[26]));
register #(.N(N)) R27 (.clk(clk), .d(wr_data), .q(r27), .rst(rst), .ena(reg_enas[27]));
register #(.N(N)) R28 (.clk(clk), .d(wr_data), .q(r28), .rst(rst), .ena(reg_enas[28]));
register #(.N(N)) R29 (.clk(clk), .d(wr_data), .q(r29), .rst(rst), .ena(reg_enas[29]));
register #(.N(N)) R30 (.clk(clk), .d(wr_data), .q(r30), .rst(rst), .ena(reg_enas[30]));
register #(.N(N)) R31 (.clk(clk), .d(wr_data), .q(r31), .rst(rst), .ena(reg_enas[31]));

always @(*) begin
	case (rd_addr0) 
		5'd00 : rd_data0 = r00;
		5'd01 : rd_data0 = r01;
		5'd02 : rd_data0 = r02;
		5'd03 : rd_data0 = r03;
		5'd04 : rd_data0 = r04;
		5'd05 : rd_data0 = r05;
		5'd06 : rd_data0 = r06;
		5'd07 : rd_data0 = r07;
		5'd08 : rd_data0 = r08;
		5'd09 : rd_data0 = r09;
		5'd10 : rd_data0 = r10;
		5'd11 : rd_data0 = r11;
		5'd12 : rd_data0 = r12;
		5'd13 : rd_data0 = r13;
		5'd14 : rd_data0 = r14;
		5'd15 : rd_data0 = r15;
		5'd16 : rd_data0 = r16;
		5'd17 : rd_data0 = r17;
		5'd18 : rd_data0 = r18;
		5'd19 : rd_data0 = r19;
		5'd20 : rd_data0 = r20;
		5'd21 : rd_data0 = r21;
		5'd22 : rd_data0 = r22;
		5'd23 : rd_data0 = r23;
		5'd24 : rd_data0 = r24;
		5'd25 : rd_data0 = r25;
		5'd26 : rd_data0 = r26;
		5'd27 : rd_data0 = r27;
		5'd28 : rd_data0 = r28;
		5'd29 : rd_data0 = r29;
		5'd30 : rd_data0 = r30;
		5'd31 : rd_data0 = r31;
		default: rd_data0 = 0;
	endcase
	case (rd_addr1)
		5'd00 : rd_data1 = r00;
		5'd01 : rd_data1 = r01;
		5'd02 : rd_data1 = r02;
		5'd03 : rd_data1 = r03;
		5'd04 : rd_data1 = r04;
		5'd05 : rd_data1 = r05;
		5'd06 : rd_data1 = r06;
		5'd07 : rd_data1 = r07;
		5'd08 : rd_data1 = r08;
		5'd09 : rd_data1 = r09;
		5'd10 : rd_data1 = r10;
		5'd11 : rd_data1 = r11;
		5'd12 : rd_data1 = r12;
		5'd13 : rd_data1 = r13;
		5'd14 : rd_data1 = r14;
		5'd15 : rd_data1 = r15;
		5'd16 : rd_data1 = r16;
		5'd17 : rd_data1 = r17;
		5'd18 : rd_data1 = r18;
		5'd19 : rd_data1 = r19;
		5'd20 : rd_data1 = r20;
		5'd21 : rd_data1 = r21;
		5'd22 : rd_data1 = r22;
		5'd23 : rd_data1 = r23;
		5'd24 : rd_data1 = r24;
		5'd25 : rd_data1 = r25;
		5'd26 : rd_data1 = r26;
		5'd27 : rd_data1 = r27;
		5'd28 : rd_data1 = r28;
		5'd29 : rd_data1 = r29;
		5'd30 : rd_data1 = r30;
		5'd31 : rd_data1 = r31;
		default: rd_data1 = 0;
	endcase
end

output wire [32*32-1:0] full_register_file;
assign full_register_file = {r31,r30,r29,r28,r27,r26,r25,r24,r23,r22,r21,r20,r19,r18,r17,r16,r15,r14,r13,r12,r11,r10,r09,r08,r07,r06,r05,r04,r03,r02,r01,r00};

task print_hex;
begin
	//print "\t" + "\n\t".join(["$display(\"r%02d::%8s::%%h\",r%02d);"%(i,x,i) for i,x in enumerate(register_names)]) #generator code (python)
	$display("r00::   $zero::%h",r00);
	$display("r01::     $at::%h",r01);
	$display("r02::     $v0::%h",r02);
	$display("r03::     $v1::%h",r03);
	$display("r04::     $a0::%h",r04);
	$display("r05::     $a1::%h",r05);
	$display("r06::     $a2::%h",r06);
	$display("r07::     $a3::%h",r07);
	$display("r08::     $t0::%h",r08);
	$display("r09::     $t1::%h",r09);
	$display("r10::     $t2::%h",r10);
	$display("r11::     $t3::%h",r11);
	$display("r12::     $t4::%h",r12);
	$display("r13::     $t5::%h",r13);
	$display("r14::     $t6::%h",r14);
	$display("r15::     $t7::%h",r15);
	$display("r16::     $s0::%h",r16);
	$display("r17::     $s1::%h",r17);
	$display("r18::     $s2::%h",r18);
	$display("r19::     $s3::%h",r19);
	$display("r20::     $s4::%h",r20);
	$display("r21::     $s5::%h",r21);
	$display("r22::     $s6::%h",r22);
	$display("r23::     $s7::%h",r23);
	$display("r24::     $t8::%h",r24);
	$display("r25::     $t9::%h",r25);
	$display("r26::     $k0::%h",r26);
	$display("r27::     $k1::%h",r27);
	$display("r28::     $gp::%h",r28);
	$display("r29::     $sp::%h",r29);
	$display("r30::     $fp::%h",r30);
	$display("r31::     $ra::%h",r31);
end
endtask

task print_decimal;
begin
	//print "\t" + "\n\t".join(["$display(\"r%02d::%8s::%%h\",r%02d);"%(i,x,i) for i,x in enumerate(register_names)]) #generator code (python)
	$display("r00::   $zero::%d",r00);
	$display("r01::     $at::%d",r01);
	$display("r02::     $v0::%d",r02);
	$display("r03::     $v1::%d",r03);
	$display("r04::     $a0::%d",r04);
	$display("r05::     $a1::%d",r05);
	$display("r06::     $a2::%d",r06);
	$display("r07::     $a3::%d",r07);
	$display("r08::     $t0::%d",r08);
	$display("r09::     $t1::%d",r09);
	$display("r10::     $t2::%d",r10);
	$display("r11::     $t3::%d",r11);
	$display("r12::     $t4::%d",r12);
	$display("r13::     $t5::%d",r13);
	$display("r14::     $t6::%d",r14);
	$display("r15::     $t7::%d",r15);
	$display("r16::     $s0::%d",r16);
	$display("r17::     $s1::%d",r17);
	$display("r18::     $s2::%d",r18);
	$display("r19::     $s3::%d",r19);
	$display("r20::     $s4::%d",r20);
	$display("r21::     $s5::%d",r21);
	$display("r22::     $s6::%d",r22);
	$display("r23::     $s7::%d",r23);
	$display("r24::     $t8::%d",r24);
	$display("r25::     $t9::%d",r25);
	$display("r26::     $k0::%d",r26);
	$display("r27::     $k1::%d",r27);
	$display("r28::     $gp::%d",r28);
	$display("r29::     $sp::%d",r29);
	$display("r30::     $fp::%d",r30);
	$display("r31::     $ra::%d",r31);
end
endtask


endmodule
`default_nettype wire


