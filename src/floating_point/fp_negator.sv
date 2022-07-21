`include "fp_consts.sv";

module FP_Negator (
    input wire [31:0] a,
    output reg [31:0] result,
    output reg qNaN,
    output reg sNaN
);

    wire [31:0] simple_negate = {~a[31], a[30:0]};

    always_comb begin
        // Reset signals
        {qNaN, sNaN, result} = 0;
        // Check if a is qNaN or sNaN
        if (a == `INFINITY_NEGATIVE_CONST | a == `INFINITY_NEGATIVE_CONST)
            result = simple_negate;
        else if (a ==? `QNAN_CONST) begin
            qNaN = 1;
            result = simple_negate;
        end else if (a ==? `SNAN_CONST) begin
            sNaN = 1;
            result = simple_negate;
        end else if (a == 0) // All bits must be zero if the input is zero
            result = 0;
        else // Everything else
            result = simple_negate;
    end
endmodule
