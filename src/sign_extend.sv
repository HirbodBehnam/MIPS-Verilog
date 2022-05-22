module(input [15:0] short, output [31:0] long);

assign long[15:0] = short;
assign long[31:16] = (short[15] ? -16'b1 : 16'b0);

endmodule
