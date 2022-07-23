`include "fp_consts.sv"

module FloatToBinary (
    input wire [31:0] in,
    output reg [31:0] out,
    output reg overflow,
    output reg underflow
);
    wire negative = in[31];
    wire signed [7:0] exponent = in[30:23] - 127;
    reg [4:0] index, fraction_counter;

    always_comb begin
        // Reset signals
        {overflow, underflow, out, index, fraction_counter} = 0;
        // Check zero
        if (in == 0 | in ==? `QNAN_CONST | in ==? `SNAN_CONST) begin
            out = 0;
        end else if (exponent > 32 | in == `INFINITY_POSITIVE_CONST | in == `INFINITY_NEGATIVE_CONST) begin
            overflow = ~negative;
            underflow = negative;
        end else if (exponent < 0) begin
            out = 0; // Too small
        end else begin
            out[exponent[4:0]] = 1; // Set the bit
            index = exponent[4:0] - 1;
            fraction_counter = 22; // last bit of fraction
            while (fraction_counter < 23 & index != 31) begin
                out[index] = in[fraction_counter];
                index--;
                fraction_counter--;
            end
            // Inverse if needed
            if (negative)
                out = -out;
        end
    end

endmodule