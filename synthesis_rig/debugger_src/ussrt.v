`default_nettype none

//universal _synchronous_ serial recieve transmit module 
//writes tx bits out, reads rx bits in
module ussrt(
	clk, rstb, sclk, tx, rx, dout, din, csb, tx_busy, rx_busy, tx_done, rx_done, tx_start
);

parameter TX_N = 8;    //number of bits in the tx stream
parameter RX_N = 8;    //number of bits in the rx stream
parameter TX_EDGE = 1; //one for positive edge, 0 for negative
parameter RX_EDGE = 1; //one for positive edge, 0 for negative
parameter TX_MSB_FIRST = 1; //one for MSB first
parameter RX_MSB_FIRST = 1; //one for MSB first
parameter CLK_DIVIDER = 1; //must be >= 1, amount by which output clock is divided

input wire clk, rstb; //a master clock that is at least 2x the desired serial clock, rstb is a synchronous reset
output reg sclk; // the serial clock

input wire csb;
input wire [TX_N-1:0] tx;
output reg [RX_N-1:0] rx;
output reg dout;
input wire din;

input wire tx_start; //used to start a transmission
reg tx_start_synced; //tx_start synced to the slower clock
input wire tx_busy, rx_busy;  //can be used to stall rx or tx processes. set to zero if unecessary
output wire tx_done, rx_done; //can be used to inform other modules that the tx or rx are done respectively

assign tx_done = (tx_counter == (TX_N-1));
assign rx_done = (rx_counter == (RX_N-1));

//state machine
reg [15:0] clk_divider_counter;
reg tx_active, rx_active;
reg [TX_N-1:0] tx_locked;
reg [RX_N-2:0] rx_buffer;
reg [$clog2(TX_N):0] tx_counter;
reg [$clog2(RX_N):0] rx_counter;

always @(posedge clk) begin
	if(~rstb) begin
		clk_divider_counter <= 0;
		sclk <= 0;
		tx_start_synced <= 0;
		tx_active <= 0;
		rx_active <= 0;
		tx_locked <= 0;
		rx_buffer <= 0;
		tx_counter <= 0;
		rx_counter <= 0;
	end
	else begin
		if(~csb) begin
			if(clk_divider_counter < CLK_DIVIDER) begin
				clk_divider_counter <= clk_divider_counter + 1;
			end
			else begin
				sclk <= ~sclk;
				clk_divider_counter <= 0;
				//TX logic
				if(TX_EDGE ^ sclk) begin  //locks to appropriate edge
					$display("tx start sync should fire?");
					tx_start_synced <= tx_start;
					if(~tx_active) begin //tx has not started yet
						if(tx_start_synced & ~tx_busy) begin
							tx_active <= 1;
							tx_locked <= tx;
							tx_counter <= tx_counter + 1;
						end
					end
					else begin //in an active tx
						if (tx_counter < (TX_N-1)) begin
							tx_counter <= tx_counter + 1;
						end
						else begin
							tx_counter <= 0;
							tx_active <= 0;
							rx_active <= 1;
							rx_counter <= 0;
						end
					end
				end
				else begin
				
				end
				//RX logic
				if(RX_EDGE ^ sclk) begin //locks to appropriate edge
					if(rx_active) begin
						if(~rx_busy) begin
							if(rx_counter < (RX_N-1)) begin
								rx_counter <= rx_counter + 1;
								if(RX_MSB_FIRST) begin
									//$display("@%t: rx_buffer[%2d] = %b", $time, RX_N-2-rx_counter, din);
									rx_buffer[RX_N-2-rx_counter] <= din;
								end
								else begin //lsb first
									rx_buffer[rx_counter] <= din;
								end
							end
							else begin
								rx_active <= 0;
								rx_counter <= 0;
								if(RX_MSB_FIRST) begin
									rx <= {rx_buffer, din};
								end
								else begin
									rx <= {din, rx_buffer};
								end
							end
						
						end
					end
				end
			end
		end
	end
end

//dout combinational logic
always @(*) begin
	if(((tx_start_synced & ~tx_busy) | tx_active )) begin
		if (tx_counter == 0) begin
			dout = TX_MSB_FIRST ? tx[0] : tx[TX_N-1];
		end
		else begin
			if(TX_MSB_FIRST) begin
				if(tx_counter == 0) begin
					dout = tx_locked[0];
				end
				else begin
					dout = tx_locked[TX_N-1-tx_counter];
				end
			end
			else begin
				dout = tx_locked[tx_counter];
			end
		end
	end
	else begin //if inactive set output to zero
		dout = 0; //TODO add parameter to set the default value
	end
end

endmodule

`default_nettype wire
