`default_nettype none

module nibble_to_char(nibble, char);
	input wire [3:0] nibble;
	output reg [6:0] char; //chars are ascii less 32 (only renderable characters)s
	
	always @(*) begin
		case(nibble)
			4'h0 : char = 7'd16;
			4'h1 : char = 7'd17;
			4'h2 : char = 7'd18;
			4'h3 : char = 7'd19;
			4'h4 : char = 7'd20;
			4'h5 : char = 7'd21;
			4'h6 : char = 7'd22;
			4'h7 : char = 7'd23;
			4'h8 : char = 7'd24;
			4'h9 : char = 7'd25;
			4'ha : char = 7'd65;
			4'hb : char = 7'd66;
			4'hc : char = 7'd67;
			4'hd : char = 7'd68;
			4'he : char = 7'd69;
			4'hf : char = 7'd70;
		endcase
	end

endmodule

`default_nettype wire
