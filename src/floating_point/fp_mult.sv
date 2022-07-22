`include "fp_consts.sv";

module FP_Multiplicator (
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] result,
    output reg overflow,
    output reg underflow
);

// mantissa + exponent + sign extraction
assign sign_a = a[31];
assign sign_b = b[31];

assign [7:0] exp_a = a[30:23];
assign [7:0] exp_b = b[30:23];

assign [23:0] mnts_a = {1, a[22:0]};
assign [23:0] mnts_b = {1, b[22:0]};

// combinational logic
integer i;
integer index_last_1_in_mantissaa_res = 0;
reg result_mnts_mul [47:0];
reg result_exp_mul [7:0];
always_comb begin
    underflow = 0;
    overflow = 0;
    // case: a = zero
    if (a == `ZERO) begin
        // case: b is either NAN or infinity
        if (b == `SNAN_CONST || b == `QNAN_CONST || b == `INFINITY_NEGATIVE_CONST || b == `INFINITY_POSITIVE_CONST)
            result = `QNAN_CONST;
        // case: b is a number
        else 
            result = `ZERO;
    
    // case: b = 0
    end else if (b == `ZERO) begin
        // case: a is either NAN or infinity
        if (a == `SNAN_CONST || a == `QNAN_CONST || a == `INFINITY_NEGATIVE_CONST || a == `INFINITY_POSITIVE_CONST)
            result = `QNAN_CONST;
        // case: b is a number
        else 
            result = `ZERO;
    end else begin
        // compute sign of result
        result[31] = sign_a ^ sign_b;
        // compute exponent result
        result_exp_mul = exp_a + exp_b - 127;
        // compute mantissa of result
        result_mnts_mul = {32'd0, 16'd0}; // reseting this reg
        result_mnts_mul = a * b;
        // truncation of mantissa multiplication result  
        for (i = 0; i < 48; i+=1) begin
            if (result_mnts_mul[i] == 1)
                index_last_1_in_mantissaa_res = i;
        end
        result[22:0] = result_mnts_mul[index_last_1_in_mantissaa_res - 1: index_last_1_in_mantissaa_res - 23]
        // exp correction:
        result_exp_mul += index_last_1_in_mantissaa_res - 23
        result[30:23] = result_exp_mul

        if (exp_a > 127 && exp_b > 127 && result_exp_mul < 127) // overflow
            overflow = 1;  
        else if (exp_a < 127 && exp_b < 127 && result_exp_mul > 127) // underflow
            underflow = 1;

    end
end

endmodule