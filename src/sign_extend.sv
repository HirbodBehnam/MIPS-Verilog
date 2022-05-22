module sign_extend(input [15:0] in, output [31:0] out);

assign out[15:0] = in;
assign out[31:16] = (in[15] ? -16'b1 : 16'b0);

endmodule
