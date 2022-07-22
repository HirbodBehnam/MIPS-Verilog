`include "fp_consts.sv";

module FP_Comparator (
    input wire [31:0] a,
    input wire [31:0] b,
    output reg lt, // Less than
    output reg eq, // Equal
    output reg gt // Greater than
);
    wire a_sign = a[31];
    wire b_sign = b[31];
    wire signed [7:0] a_exponent = a[30:23] - 127;
    wire signed [7:0] b_exponent = b[30:23] - 127;
    wire [22:0] a_fraction = a[22:0];
    wire [22:0] b_fraction = b[22:0];

    always_comb begin
        // Reset everything
        {lt, eq, gt} = 0;
        // Check NaN. NaN are niether equal, less than or greater than each other
        if (a ==? `QNAN_CONST | a ==? `SNAN_CONST | b ==? `QNAN_CONST | b ==? `SNAN_CONST) begin
            // Nothing to to. Already resetted
        end else begin
            // If they have same bits, they are equal
            if (a == b) begin
                eq = 1;
            end else begin // a and b are not equal
                // Check infinity
                if (a == `INFINITY_POSITIVE_CONST) begin
                    gt = b != `INFINITY_POSITIVE_CONST; // If b is not infinity, then it's always less than a
                end else if (a == `INFINITY_NEGATIVE_CONST) begin
                    lt = b != `INFINITY_NEGATIVE_CONST; // If b is not -infinity, then it's always greater than a
                end else if (b == `INFINITY_POSITIVE_CONST) begin
                    lt = a != `INFINITY_POSITIVE_CONST; // If a is not infinity, then it's always less than a
                end else if (b == `INFINITY_NEGATIVE_CONST) begin
                    gt = a != `INFINITY_NEGATIVE_CONST; // If a is not -infinity, then it's always greater than a
                end else begin
                    // Normal numbers!
                    // Note: No need to check for equal numbers because they are handled above
                    if (a == 0) begin
                        gt = b_sign == 1; // if b is negative then a(0) is greater than b! Note that b is not equal to zero if a is also zero (handled above)
                        lt = ~gt; // If not greater than [and not equal] then it is less than
                    end else if (b == 0) begin
                        gt = a_sign == 0; // if a is positive then a is greater than b(0)
                        lt = ~gt; // If not greater than [and not equal] then it is less than
                    end else begin // Non zero numbers
                        // Because numbers cannot be equal we just define the gt and lt will be calculated from !lt
                        // Check sign
                        if (a_sign == 0 & b_sign == 0) begin // Both positive
                            if (a_exponent > b_exponent)
                                gt = 1; // always
                            else if (a_exponent == b_exponent)
                                gt = a_fraction > b_fraction;
                            else // a_exponent < b_exponent
                                gt = 0;
                        end else if (a_sign == 1 & b_sign == 1) begin // Both negative
                            // Just like above but mirrored
                            if (a_exponent > b_exponent)
                                gt = 0; // always
                            else if (a_exponent == b_exponent)
                                gt = a_fraction < b_fraction;
                            else // a_exponent < b_exponent
                                gt = 1;
                        end else begin // One positive one negative
                            gt = ~a_sign; // If a is positive then b is negative so a > b
                        end
                        // Calculate lt
                        lt = ~gt;
                    end
                end
            end
        end
    end
endmodule
