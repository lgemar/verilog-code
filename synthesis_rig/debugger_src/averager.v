module averager(
	cclk, rstb, ena,
	raw,
	averaged
);

parameter N = 8;
parameter M = 2;

input cclk, rstb, ena;

input  [(N-1):0] raw;
output reg [(N-1):0] averaged;

reg [(N+M-1):0] sum;
reg [M-1:0] counter;

always @(posedge cclk) begin
	if(~rstb) begin
		sum <= 0;
		counter <= 0;
		averaged <= 0;
	end
	else begin
		if(ena) begin
			sum <= sum + raw;
			counter <= counter + 1;
			if(counter == 0) begin
				averaged <= sum >> M;
				sum <= 0;
			end
			
		end
	end
end

endmodule
