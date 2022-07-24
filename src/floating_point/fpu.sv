`include "src/floating_point/fpu_opcodes.sv"
`include "src/floating_point/fp_consts.sv"
`include "src/floating_point/fp_negator.sv"
`include "src/floating_point/fp_adder_subtractor.sv"
`include "src/floating_point/fp_mult.sv"
`include "src/floating_point/fp_div.sv"
`include "src/floating_point/fp_rounder.sv"
`include "src/floating_point/binary_to_float.sv"
`include "src/floating_point/float_to_binary.sv"
`include "src/floating_point/fp_comparator.sv"

module FPU (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] opcode,
    output reg [31:0] result,
    output reg divide_by_zero,
    output reg inexact,
    output reg overflow,
    output reg underflow,
    output wire qNaN,
    output wire sNaN
);
    // NaN checks
    assign qNaN = result ==? `QNAN_CONST;
    assign sNaN = result ==? `SNAN_CONST;

    // Output of modules
    wire adder_mode = opcode == `FPU_ADD;
    wire [31:0] negator_out, adder_out, mult_out, div_out, round_out, float_to_binary_out, binary_to_float_out;
    wire adder_overflow, adder_underflow, adder_inexact;
    wire mult_overflow, mult_underflow, div_overflow, div_underflow, rounder_overflow, rounder_underflow;
    wire div_by_zero;
    wire b2f_inexact;
    wire f2b_overflow, f2b_underflow;

    // Instantiate modules
    FP_Negator negator(a, negator_out);
    FP_Adder adder(a, b, adder_mode, adder_out, adder_underflow, adder_overflow, adder_inexact);
    FP_Multiplicator multiplier(a, b, mult_out, mult_overflow, mult_underflow);
    FP_Dividor divisor(a, b, div_out, div_by_zero, div_overflow, div_underflow);
    FP_Rounder rounder(a, round_out, rounder_overflow, rounder_underflow);
    BinaryToFloat b2f(a, binary_to_float_out, b2f_inexact);
    FloatToBinary f2b(a, float_to_binary_out, f2b_overflow, f2b_underflow);

    // Compare
    wire lt, eq, gt;
    FP_Comparator comparator(a, b, lt, eq, gt);

    always_comb begin
        {divide_by_zero, inexact, overflow, underflow} = 0;
        // Check the opcode
        case (opcode)
            `FPU_ADD: begin
                result = adder_out;
                inexact = adder_inexact;
                overflow = adder_overflow;
                underflow = adder_underflow;
            end
            `FPU_SUB: begin
                result = adder_out;
                inexact = adder_inexact;
                overflow = adder_overflow;
                underflow = adder_underflow;
            end
            `FPU_MULT: begin
                result = mult_out;
                overflow = mult_overflow;
                underflow = mult_underflow;
            end
            `FPU_DIV: begin
                result = div_out;
                divide_by_zero = div_by_zero;
                overflow = div_overflow;
                underflow = div_underflow;
            end
            `FPU_NEGATE: begin
                result = negator_out;
            end
            `FPU_ROUND: begin
                result = round_out;
                overflow = rounder_overflow;
                underflow = rounder_underflow;
            end
            `FPU_FLOAT_TO_BINARY: begin
                result = float_to_binary_out;
                overflow = f2b_overflow;
                underflow = f2b_underflow;
            end
            `FPU_BINARY_TO_FLOAT: begin
                result = binary_to_float_out;
                inexact = b2f_inexact;
            end
            `FPU_COMP_LT: result = {31'b0, lt};
            `FPU_COMP_LE: result = {31'b0, lt | eq};
            `FPU_COMP_EQ: result = {31'b0, eq};
            `FPU_COMP_NQ: result = {31'b0, ~eq};
            `FPU_COMP_GT: result = {31'b0, gt};
            `FPU_COMP_GE: result = {31'b0, gt | eq};
            default: begin
                result = 0;
                $display("INVALID FPU OPCODE");
            end
        endcase
    end
endmodule