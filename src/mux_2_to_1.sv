module Mux2To1 (
    input wire select,
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] out
);
    assign out = select ? b : a;
endmodule