`default_nettype none

//based on http://www.eewiki.net/display/LOGIC/Debounce+Logic+Circuit+%28with+Verilog+example%29

module one_shot(clk, rst, trigger, pulse, one_shot);
input wire clk, rst, trigger;
output reg pulse = 0;
output reg one_shot = 0; //high if we are actively one-shotting

parameter PULSE_WIDTH = 1; //cycles pulse should stay high.
parameter DEAD_TIME   = 100; //cycles to wait between pulses
parameter COUNTER_WIDTH = 32;
reg[COUNTER_WIDTH-1:0] counter = 0;

always @(posedge clk) begin
	if(rst) begin
		pulse <= 0;
		counter <= PULSE_WIDTH;
		one_shot <= 0;
	end
	else begin
		if(one_shot) begin //in a one shot
			if(pulse) begin  //still having an output pulse
				if(counter == 0) begin
					pulse <= 0;
					counter <= counter + 1;
				end
				else begin
					counter <= counter - 1;
					pulse <= 1;
				end
			end
			else begin  // waiting for the next input
				pulse <= 0;
				if (counter < DEAD_TIME) begin
					counter <= counter + 1;
				end
				else begin
					counter <= PULSE_WIDTH;
					one_shot <= 0;
				end
			end
		end
		else begin //in idle state
			counter <= PULSE_WIDTH;
			if(trigger) begin
				pulse <= 1;
				one_shot <= 1;
				counter <= counter -1;
			end
			else begin
				pulse <= 0;
				one_shot <= 0;
			end
		end
	end
end
endmodule

`default_nettype wire
