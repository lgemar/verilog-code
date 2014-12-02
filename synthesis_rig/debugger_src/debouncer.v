`default_nettype none

//based on http://www.eewiki.net/display/LOGIC/Debounce+Logic+Circuit+%28with+Verilog+example%29

module debouncer(clk, rst, bouncy, debounced);	
	parameter CYCLES      = 10;
	parameter RESET_VALUE = 1'b0;
	parameter COUNTER_WIDTH = 32;
	
	input wire clk, rst, bouncy;
	output reg debounced = RESET_VALUE;

	reg[COUNTER_WIDTH-1:0] counter = 0;
	
	//input shift register
	reg [1:0] shift_in = {2{RESET_VALUE}};	

	always @(posedge clk) begin
		if(rst) begin
			shift_in[0] <= RESET_VALUE;
			shift_in[1] <= RESET_VALUE;
			debounced <= RESET_VALUE;
			counter <= 0;
		end
		else begin
			shift_in[0] <= bouncy;
			shift_in[1] <= shift_in[0];
			
			if(shift_in[0] ^ shift_in[1]) begin
				counter <= 0;
			end
			else if( counter < CYCLES) begin
				counter <= counter + 1;
			end
			else begin
				debounced <= shift_in[1];
				counter <= 0;
			end
			
		end
	end
	
endmodule

`default_nettype wire
