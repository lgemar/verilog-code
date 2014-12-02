module register(clk, rst, d, q, ena);
	parameter N = 32;
	input wire clk, rst, ena;
	input wire [N-1:0] d;
	output reg [N-1:0] q = 0;

	always @(posedge clk) begin
		if(rst) begin
			q <= 0;
		end
		else begin
			if (ena) begin
				q <= d;
			end
			else begin
				q <= q;
			end
		end
	end
endmodule
