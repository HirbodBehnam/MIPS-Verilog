`include "src/floating_point/fp_consts.sv"
`include "src/floating_point/fp_adder_subtractor.sv"
`include "src/floating_point/float_to_binary.sv"

module FP_Rounder (
    input wire [31:0] in,
    output wire [31:0] out,
    output wire overflow,
    output wire underflow
);
    wire [31:0] in_plus_half;

    // At first add 0.5 to input
    FP_Adder adder(.a(in), .b(`POSITIVE_HALF), .add_sub_not(1'b1), .result(in_plus_half), .underflow(), .overflow(), .inexcat());
    // Then floor it
    FloatToBinary floor(in_plus_half, out, overflow, underflow);
endmodule