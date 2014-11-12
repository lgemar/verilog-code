`timescale 1 ps / 1 ps
`default_nettype none
module main(
	input  wire rstb, button_left, button_right,
	input  wire SYS_CLK,

	output wire [3:0] TMDS,
	output wire [3:0] TMDSB
);
	
	
	
	wire cpu_clk, gpu_clk;
	assign cpu_clk = clk50m_bufg; //contact your lab tf if this clock is too fast for your design!
	assign gpu_clk = clk50m_bufg; //do not change

	//memory for MIPS synthesis demo
	wire [31:0] cpu_mem_rd_data, cpu_mem_wr_data, cpu_mem_addr;
	wire cpu_mem_wr_ena;
	
	wire [31:0] gpu_mem_rd_data, gpu_mem_wr_data, gpu_mem_addr;
	wire gpu_mem_wr_ena;

	memory MEMORY (
		.cpu_clk(cpu_clk), .cpu_mem_addr(cpu_mem_addr), .cpu_mem_wr_ena(cpu_mem_wr_ena), .cpu_mem_wr_data(cpu_mem_wr_data), .cpu_mem_rd_data(cpu_mem_rd_data),
		.gpu_clk(gpu_clk),    .gpu_mem_addr(gpu_mem_addr), .gpu_mem_wr_ena(gpu_mem_wr_ena), .gpu_mem_wr_data(gpu_mem_wr_data), .gpu_mem_rd_data(gpu_mem_rd_data)
	);
	wire [31:0] PC;
	mips CPU (
		.clk(cpu_clk), .rstb(rstb), .PC(PC),
		.mem_addr(cpu_mem_addr),
		.mem_wr_ena(cpu_mem_wr_ena),
		.mem_wr_data(cpu_mem_wr_data),
		.mem_rd_data(cpu_mem_rd_data)
	);
	
	wire [7:0] red_data, green_data, blue_data;
	gpu GPU (.cclk(gpu_clk), .pclk(pclk), .rstb(rstb), .red(red_data), .green(green_data), .blue(blue_data), .x(pixel_x), .y(pixel_y), .vsync(vsync),
		.mem_addr(gpu_mem_addr), .mem_rd_data(gpu_mem_rd_data), .mem_wr_data(gpu_mem_wr_data), .mem_wr_ena(gpu_mem_wr_ena), .PC(PC),
		//debugging pins (replace with any signal you want to see.  You will have to deal with clocking though (this is sampled rarely)
		.dbg0(32'd0), .dbg1(32'd1), .dbg2(32'd2), .dbg3(32'd3), .dbg4(32'd4), .dbg5(32'd5), .dbg6(32'd6), .dbg7(32'd7), .dbg8(32'd8), .dbg9(32'd9), .dbg10(32'd10), .dbg11(32'd11), .dbg12(32'd12), .dbg13(32'd13), .dbg14(32'd14), .dbg15(32'd15), .dbg16(32'd16), .dbg17(32'd17), .dbg18(32'd18), .dbg19(32'd19), .dbg20(32'd20), .dbg21(32'd21), .dbg22(32'd22), .dbg23(32'd23), .dbg24(32'd24), .dbg25(32'd25), .dbg26(32'd26), .dbg27(32'd27), .dbg28(32'd28), .dbg29(32'd29), .dbg30(32'd30), .dbg31(32'd31)
   );
	
	/* do not modify anything under this line! */
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// following code is based on a xilinx app note on driving dvi using the spartan6.  The code is a bit... complicated.  Don't use it as an example of good coding style.       //
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	`define   SW_VGA       4'b0000
	`define   SW_SVGA      4'b0001
	`define   SW_XGA       4'b0011
	`define   SW_HDTV720P  4'b0010
	`define   SW_SXGA      4'b1000
	
	wire RSTBTN;
	assign RSTBTN = ~rstb;

	parameter resolution = `SW_HDTV720P;

	 //clock generation
	wire locked, reset, clk50m, clk50m_bufg, pwrup, sysclk, pclk_lckd;
	//real time resolution switching
	wire [3:0] SW, sws_sync;
	reg [3:0] sws_sync_q;
	wire sw0_rdy, sw1_rdy, sw2_rdy, sw3_rdy;
	wire busy;
	wire gopclk, active;
	reg [7:0] pclk_M, pclk_D;
	wire progdone, progen, progdata;
	wire          clkfx, pclk;
	wire pllclk0, pllclk1, pllclk2;
	wire pclkx2, pclkx10, pll_lckd;
	wire clkfbout;
	wire serdesstrobe;
	wire bufpll_lock;

	reg [10:0] tc_hsblnk;
	reg [10:0] tc_hssync;
	reg [10:0] tc_hesync;
	reg [10:0] tc_heblnk;
	reg [10:0] tc_vsblnk;
	reg [10:0] tc_vssync;
	reg [10:0] tc_vesync;
	reg [10:0] tc_veblnk;

	reg hvsync_polarity; //1-Negative, 0-Positive

	wire VGA_HSYNC_INT, VGA_VSYNC_INT;
	wire   [10:0] pixel_x;
	wire   [10:0] pixel_y;

	reg active_q;
	reg vsync, hsync;
	wire hblnk, vblnk;
	reg VGA_HSYNC, VGA_VSYNC;
	reg de;
	wire [4:0] tmds_data0, tmds_data1, tmds_data2;

	wire [2:0] tmdsint;

	wire serdes_rst;
		
	// Create global clock and synchronous system reset.                //
	IBUF sysclk_buf (.I(SYS_CLK), .O(sysclk));
	BUFIO2 #(.DIVIDE_BYPASS("FALSE"), .DIVIDE(2))
	sysclk_div (.DIVCLK(clk50m), .IOCLK(), .SERDESSTROBE(), .I(sysclk));
	BUFG clk50m_bufgbufg (.I(clk50m), .O(clk50m_bufg));
	SRL16E #(.INIT(16'h1)) pwrup_0 (
		.Q(pwrup),
		.A0(1'b1),
		.A1(1'b1),
		.A2(1'b1),
		.A3(1'b1),
		.CE(pclk_lckd),
		.CLK(clk50m_bufg),
		.D(1'b0)
	);

	SRL16E SRL16E_0 (
		.Q(gopclk),
		.A0(1'b1),
		.A1(1'b1),
		.A2(1'b1),
		.A3(1'b1),
		.CE(1'b1),
		.CLK(clk50m_bufg),
		.D(pwrup)
	);
	defparam SRL16E_0.INIT = 16'h0;
	always @ (posedge clk50m_bufg) begin
		if(pwrup) begin
			case (resolution)
				`SW_VGA: begin //25 MHz pixel clock
					pclk_M <= 8'd2 - 8'd1;
					pclk_D <= 8'd4 - 8'd1;
				end

				`SW_SVGA: //40 MHz pixel clock
				begin
					pclk_M <= 8'd4 - 8'd1;
					pclk_D <= 8'd5 - 8'd1;
				end
				`SW_XGA: //65 MHz pixel clock
				begin
					pclk_M <= 8'd13 - 8'd1;
					pclk_D <= 8'd10 - 8'd1;
				end
				`SW_SXGA: //108 MHz pixel clock
				begin
					pclk_M <= 8'd54 - 8'd1;
					pclk_D <= 8'd25 - 8'd1;
				end

				default: //74.25 MHz pixel clock
				begin
					pclk_M <= 8'd37 - 8'd1;
					pclk_D <= 8'd25 - 8'd1;
				end
			endcase
		end
	end

	// DCM_CLKGEN SPI controller
	dcmspi dcmspi_0 (
		.RST(pwrup),          //Synchronous Reset
		.PROGCLK(clk50m_bufg), //SPI clock
		.PROGDONE(progdone),   //DCM is ready to take next command
		.DFSLCKD(pclk_lckd),
		.M(pclk_M),            //DCM M value
		.D(pclk_D),            //DCM D value
		.GO(gopclk),           //Go programme the M and D value into DCM(1 cycle pulse)
		.BUSY(busy),
		.PROGEN(progen),       //SlaveSelect,
		.PROGDATA(progdata)    //CommandData
	);

	// DCM_CLKGEN to generate a pixel clock with a variable frequency
	DCM_CLKGEN #(
		.CLKFX_DIVIDE (21),
		.CLKFX_MULTIPLY (31),
		.CLKIN_PERIOD(20.000)
	)
	PCLK_GEN_INST (
		.CLKFX(clkfx),
		.CLKFX180(),
		.CLKFXDV(),
		.LOCKED(pclk_lckd),
		.PROGDONE(progdone),
		.STATUS(),
		.CLKIN(clk50m),
		.FREEZEDCM(1'b0),
		.PROGCLK(clk50m_bufg),
		.PROGDATA(progdata),
		.PROGEN(progen),
		.RST(1'b0)
	);

	// Pixel Rate clock buffer
	BUFG pclkbufg (.I(pllclk1), .O(pclk));

	// 2x pclk is going to be used to drive OSERDES2
	// on the GCLK side
	BUFG pclkx2bufg (.I(pllclk2), .O(pclkx2));

	// 10x pclk is used to drive IOCLK network so a bit rate reference
	// can be used by OSERDES2
	PLL_BASE # (
		.CLKIN_PERIOD(13),
		.CLKFBOUT_MULT(10), //set VCO to 10x of CLKIN
		.CLKOUT0_DIVIDE(1),
		.CLKOUT1_DIVIDE(10),
		.CLKOUT2_DIVIDE(5),
		.COMPENSATION("INTERNAL")
	) PLL_OSERDES (
		.CLKFBOUT(clkfbout),
		.CLKOUT0(pllclk0),
		.CLKOUT1(pllclk1),
		.CLKOUT2(pllclk2),
		.CLKOUT3(),
		.CLKOUT4(),
		.CLKOUT5(),
		.LOCKED(pll_lckd),
		.CLKFBIN(clkfbout),
		.CLKIN(clkfx),
		.RST(~pclk_lckd)
	);
	
	BUFPLL #(.DIVIDE(5)) ioclk_buf (.PLLIN(pllclk0), .GCLK(pclkx2), .LOCKED(pll_lckd),
	.IOCLK(pclkx10), .SERDESSTROBE(serdesstrobe), .LOCK(bufpll_lock));

	synchro #(.INITIALIZE("LOGIC1"))
	synchro_reset (.async(!pll_lckd),.sync(reset),.clk(pclk));

	///////////////////////////////////////////////////////////////////////////
	// Video Timing Parameters
	///////////////////////////////////////////////////////////////////////////
	//1280x1024@60HZ
	parameter HPIXELS_SXGA = 11'd1280; //Horizontal Live Pixels
	parameter VLINES_SXGA = 11'd1024;  //Vertical Live ines
	parameter HSYNCPW_SXGA = 11'd112;  //HSYNC Pulse Width
	parameter VSYNCPW_SXGA = 11'd3;    //VSYNC Pulse Width
	parameter HFNPRCH_SXGA = 11'd48;   //Horizontal Front Portch
	parameter VFNPRCH_SXGA = 11'd1;    //Vertical Front Portch
	parameter HBKPRCH_SXGA = 11'd248;  //Horizontal Front Portch
	parameter VBKPRCH_SXGA = 11'd38;   //Vertical Front Portch

	//1280x720@60HZ
	parameter HPIXELS_HDTV720P = 11'd1280; //Horizontal Live Pixels
	parameter VLINES_HDTV720P  = 11'd720;  //Vertical Live ines
	parameter HSYNCPW_HDTV720P = 11'd80;  //HSYNC Pulse Width
	parameter VSYNCPW_HDTV720P = 11'd5;    //VSYNC Pulse Width
	parameter HFNPRCH_HDTV720P = 11'd72;   //Horizontal Front Portch
	parameter VFNPRCH_HDTV720P = 11'd3;    //Vertical Front Portch
	parameter HBKPRCH_HDTV720P = 11'd216;  //Horizontal Front Portch
	parameter VBKPRCH_HDTV720P = 11'd22;   //Vertical Front Portch

	//1024x768@60HZ
	parameter HPIXELS_XGA = 11'd1024; //Horizontal Live Pixels
	parameter VLINES_XGA  = 11'd768;  //Vertical Live ines
	parameter HSYNCPW_XGA = 11'd136;  //HSYNC Pulse Width
	parameter VSYNCPW_XGA = 11'd6;    //VSYNC Pulse Width
	parameter HFNPRCH_XGA = 11'd24;   //Horizontal Front Portch
	parameter VFNPRCH_XGA = 11'd3;    //Vertical Front Portch
	parameter HBKPRCH_XGA = 11'd160;  //Horizontal Front Portch
	parameter VBKPRCH_XGA = 11'd29;   //Vertical Front Portch

	//800x600@60HZ
	parameter HPIXELS_SVGA = 11'd800; //Horizontal Live Pixels
	parameter VLINES_SVGA  = 11'd600; //Vertical Live ines
	parameter HSYNCPW_SVGA = 11'd128; //HSYNC Pulse Width
	parameter VSYNCPW_SVGA = 11'd4;   //VSYNC Pulse Width
	parameter HFNPRCH_SVGA = 11'd40;  //Horizontal Front Portch
	parameter VFNPRCH_SVGA = 11'd1;   //Vertical Front Portch
	parameter HBKPRCH_SVGA = 11'd88;  //Horizontal Front Portch
	parameter VBKPRCH_SVGA = 11'd23;  //Vertical Front Portch

	//640x480@60HZ
	parameter HPIXELS_VGA = 11'd640; //Horizontal Live Pixels
	parameter VLINES_VGA  = 11'd480; //Vertical Live ines
	parameter HSYNCPW_VGA = 11'd96;  //HSYNC Pulse Width
	parameter VSYNCPW_VGA = 11'd2;   //VSYNC Pulse Width
	parameter HFNPRCH_VGA = 11'd16;  //Horizontal Front Portch
	parameter VFNPRCH_VGA = 11'd11;  //Vertical Front Portch
	parameter HBKPRCH_VGA = 11'd48;  //Horizontal Front Portch
	parameter VBKPRCH_VGA = 11'd31;  //Vertical Front Portch
		
	always @ (*) begin
		case (resolution)
			`SW_VGA: begin
				hvsync_polarity = 1'b1;

				tc_hsblnk = HPIXELS_VGA - 11'd1;
				tc_hssync = HPIXELS_VGA - 11'd1 + HFNPRCH_VGA;
				tc_hesync = HPIXELS_VGA - 11'd1 + HFNPRCH_VGA + HSYNCPW_VGA;
				tc_heblnk = HPIXELS_VGA - 11'd1 + HFNPRCH_VGA + HSYNCPW_VGA + HBKPRCH_VGA;
				tc_vsblnk =  VLINES_VGA - 11'd1;
				tc_vssync =  VLINES_VGA - 11'd1 + VFNPRCH_VGA;
				tc_vesync =  VLINES_VGA - 11'd1 + VFNPRCH_VGA + VSYNCPW_VGA;
				tc_veblnk =  VLINES_VGA - 11'd1 + VFNPRCH_VGA + VSYNCPW_VGA + VBKPRCH_VGA;
			end

			`SW_SVGA: begin
				hvsync_polarity = 1'b0;

				tc_hsblnk = HPIXELS_SVGA - 11'd1;
				tc_hssync = HPIXELS_SVGA - 11'd1 + HFNPRCH_SVGA;
				tc_hesync = HPIXELS_SVGA - 11'd1 + HFNPRCH_SVGA + HSYNCPW_SVGA;
				tc_heblnk = HPIXELS_SVGA - 11'd1 + HFNPRCH_SVGA + HSYNCPW_SVGA + HBKPRCH_SVGA;
				tc_vsblnk =  VLINES_SVGA - 11'd1;
				tc_vssync =  VLINES_SVGA - 11'd1 + VFNPRCH_SVGA;
				tc_vesync =  VLINES_SVGA - 11'd1 + VFNPRCH_SVGA + VSYNCPW_SVGA;
				tc_veblnk =  VLINES_SVGA - 11'd1 + VFNPRCH_SVGA + VSYNCPW_SVGA + VBKPRCH_SVGA;
			end

			`SW_XGA: begin
				hvsync_polarity = 1'b1;

				tc_hsblnk = HPIXELS_XGA - 11'd1;
				tc_hssync = HPIXELS_XGA - 11'd1 + HFNPRCH_XGA;
				tc_hesync = HPIXELS_XGA - 11'd1 + HFNPRCH_XGA + HSYNCPW_XGA;
				tc_heblnk = HPIXELS_XGA - 11'd1 + HFNPRCH_XGA + HSYNCPW_XGA + HBKPRCH_XGA;
				tc_vsblnk =  VLINES_XGA - 11'd1;
				tc_vssync =  VLINES_XGA - 11'd1 + VFNPRCH_XGA;
				tc_vesync =  VLINES_XGA - 11'd1 + VFNPRCH_XGA + VSYNCPW_XGA;
				tc_veblnk =  VLINES_XGA - 11'd1 + VFNPRCH_XGA + VSYNCPW_XGA + VBKPRCH_XGA;
			end

			`SW_SXGA: begin
				hvsync_polarity = 1'b0; // positive polarity

				tc_hsblnk = HPIXELS_SXGA - 11'd1;
				tc_hssync = HPIXELS_SXGA - 11'd1 + HFNPRCH_SXGA;
				tc_hesync = HPIXELS_SXGA - 11'd1 + HFNPRCH_SXGA + HSYNCPW_SXGA;
				tc_heblnk = HPIXELS_SXGA - 11'd1 + HFNPRCH_SXGA + HSYNCPW_SXGA + HBKPRCH_SXGA;
				tc_vsblnk =  VLINES_SXGA - 11'd1;
				tc_vssync =  VLINES_SXGA - 11'd1 + VFNPRCH_SXGA;
				tc_vesync =  VLINES_SXGA - 11'd1 + VFNPRCH_SXGA + VSYNCPW_SXGA;
				tc_veblnk =  VLINES_SXGA - 11'd1 + VFNPRCH_SXGA + VSYNCPW_SXGA + VBKPRCH_SXGA;
			end

			default: begin //SW_HDTV720P
				hvsync_polarity = 1'b0;

				tc_hsblnk = HPIXELS_HDTV720P - 11'd1;
				tc_hssync = HPIXELS_HDTV720P - 11'd1 + HFNPRCH_HDTV720P;
				tc_hesync = HPIXELS_HDTV720P - 11'd1 + HFNPRCH_HDTV720P + HSYNCPW_HDTV720P;
				tc_heblnk = HPIXELS_HDTV720P - 11'd1 + HFNPRCH_HDTV720P + HSYNCPW_HDTV720P + HBKPRCH_HDTV720P;
				tc_vsblnk =  VLINES_HDTV720P - 11'd1;
				tc_vssync =  VLINES_HDTV720P - 11'd1 + VFNPRCH_HDTV720P;
				tc_vesync =  VLINES_HDTV720P - 11'd1 + VFNPRCH_HDTV720P + VSYNCPW_HDTV720P;
				tc_veblnk =  VLINES_HDTV720P - 11'd1 + VFNPRCH_HDTV720P + VSYNCPW_HDTV720P + VBKPRCH_HDTV720P;
			end
		endcase
	end
	timing timing_inst (
		.tc_hsblnk(tc_hsblnk), //input
		.tc_hssync(tc_hssync), //input
		.tc_hesync(tc_hesync), //input
		.tc_heblnk(tc_heblnk), //input
		.hcount(pixel_x), //output
		.hsync(VGA_HSYNC_INT), //output
		.hblnk(hblnk), //output
		.tc_vsblnk(tc_vsblnk), //input
		.tc_vssync(tc_vssync), //input
		.tc_vesync(tc_vesync), //input
		.tc_veblnk(tc_veblnk), //input
		.vcount(pixel_y), //output
		.vsync(VGA_VSYNC_INT), //output
		.vblnk(vblnk), //output
		.restart(reset),
		.clk(pclk)
	);

	/////////////////////////////////////////
	// V/H SYNC and DE generator
	/////////////////////////////////////////
	assign active = !hblnk && !vblnk;
	
	always @ (posedge pclk) begin
		hsync <= VGA_HSYNC_INT ^ hvsync_polarity ;
		vsync <= VGA_VSYNC_INT ^ hvsync_polarity ;
		VGA_HSYNC <= hsync;
		VGA_VSYNC <= vsync;
	
		active_q <= active;
		de <= active_q;
	end


	////////////////////////////////////////////////////////////////
	// DVI Encoder
	////////////////////////////////////////////////////////////////

	dvi_encoder enc0 (
		.clkin      (pclk),
		.clkx2in    (pclkx2),
		.rstin      (reset),
		.blue_din   (blue_data),
		.green_din  (green_data),
		.red_din    (red_data),
		.hsync      (VGA_HSYNC),
		.vsync      (VGA_VSYNC),
		.de         (de),
		.tmds_data0 (tmds_data0),
		.tmds_data1 (tmds_data1),
		.tmds_data2 (tmds_data2)
	);
	
	assign serdes_rst = RSTBTN | ~bufpll_lock;

	serdes_n_to_1 #(.SF(5)) oserdes0 (
		.ioclk(pclkx10),
		.serdesstrobe(serdesstrobe),
		.reset(serdes_rst),
		.gclk(pclkx2),
		.datain(tmds_data0),
		.iob_data_out(tmdsint[0])
	);

	serdes_n_to_1 #(.SF(5)) oserdes1 (
		.ioclk(pclkx10),
		.serdesstrobe(serdesstrobe),
		.reset(serdes_rst),
		.gclk(pclkx2),
		.datain(tmds_data1),
		.iob_data_out(tmdsint[1])
	);

	serdes_n_to_1 #(.SF(5)) oserdes2 (
		.ioclk(pclkx10),
		.serdesstrobe(serdesstrobe),
		.reset(serdes_rst),
		.gclk(pclkx2),
		.datain(tmds_data2),
		.iob_data_out(tmdsint[2])
	);

	OBUFDS TMDS0 (.I(tmdsint[0]), .O(TMDS[0]), .OB(TMDSB[0])) ;
	OBUFDS TMDS1 (.I(tmdsint[1]), .O(TMDS[1]), .OB(TMDSB[1])) ;
	OBUFDS TMDS2 (.I(tmdsint[2]), .O(TMDS[2]), .OB(TMDSB[2])) ;

	reg [4:0] tmdsclkint = 5'b00000;
	reg toggle = 1'b0;

	always @ (posedge pclkx2 or posedge serdes_rst) begin
		if (serdes_rst) begin 
			toggle <= 1'b0;
		end
		else begin
			toggle <= ~toggle;
		end
	end

	always @ (posedge pclkx2) begin
		if (toggle) begin 
			tmdsclkint <= 5'b11111;
		end
		else begin
			tmdsclkint <= 5'b00000;
		end
	end

	wire tmdsclk;

	serdes_n_to_1 #(.SF(5)) clkout (
		.iob_data_out (tmdsclk),
		.ioclk        (pclkx10),
		.serdesstrobe (serdesstrobe),
		.gclk         (pclkx2),
		.reset        (serdes_rst),
		.datain       (tmdsclkint)
	);

	OBUFDS TMDS3 (.I(tmdsclk), .O(TMDS[3]), .OB(TMDSB[3])) ;// clock

endmodule

`default_nettype wire
