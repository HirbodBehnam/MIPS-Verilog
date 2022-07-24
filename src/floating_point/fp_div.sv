`include "src/floating_point/fp_consts.sv";

module FP_Dividor (
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] result,
    output reg divide_by_zero,
    output reg overflow,
    output reg underflow
); // result = a / b (Quotient of division)

// mantissa + exponent + sign extraction
wire sign_a = a[31];
wire sign_b = b[31];

wire [7:0] exp_a = a[30:23];
wire [7:0] exp_b = b[30:23];

wire [23:0] mnts_a = {1'b1, a[22:0]};
wire [23:0] mnts_b = {1'b1, b[22:0]};


// combinational logic
reg [47:0] result_mnts_div;
reg [7:0] result_exp_div;
always_comb begin
    underflow = 0;
    overflow = 0;
    result_mnts_div = 0;
    result_exp_div = 0;
    divide_by_zero = 0;
    // First, handling some edgecases:
    //1. Either a or b is NAN
    if (a ==? `QNAN_CONST || a ==? `SNAN_CONST || b ==? `QNAN_CONST || b ==? `SNAN_CONST) begin
        result = `QNAN_SAMPLE_CONST;
    end
    //2. Division By Zero
    else if (b == `ZERO) begin
        // Zero Dividend
        if (a == `ZERO)
            result = `QNAN_SAMPLE_CONST;
        else begin
            result = `INFINITY_POSITIVE_CONST; 
            result[31] = sign_a ^ sign_b;
        end
        divide_by_zero = 1;
    end 
    //3. Division by Infinity
    else if (b ==? `INFINITY_GENERAL_PATTERN) begin 
        // Infinity Dividend
        if (a ==? `INFINITY_GENERAL_PATTERN) 
            result = `QNAN_SAMPLE_CONST;
        else 
            result = `ZERO;
    end
    //4. Dividend Zero (Divisor is not an edgecase)
    else if (a == `ZERO) begin
        result = `ZERO;
    end 
    // 5. Dividend Infinity (Divisor is not an edgecase)
    else if (a ==? `INFINITY_GENERAL_PATTERN) begin
        result = `INFINITY_POSITIVE_CONST;
        result[31]= sign_a ^ sign_b;
    end
    // All edgecases have been covered!
    // Normal Cases:
    else begin
        // compute sign of result
        result[31] = sign_a ^ sign_b;
        // compute exponent of result
        result_exp_div = exp_a - exp_b + 127;
        // compute mantissa of result
        result_mnts_div = {mnts_a, 24'h000000};
        result_mnts_div /= {24'h000000, mnts_b};
        
        // normalizing mantiassa of result
        // case: 0.5 < mnts_res < 1  
        if (mnts_a < mnts_b) begin
            result[22:0] = result_mnts_div[22:0];
            result_exp_div -= 1;
        end else if (mnts_a == mnts_b) begin
            result[22:0] = 0;
        end else begin
            result[22:0] = result_mnts_div[23:1];
            
        end
        // affect 'result' by calculated exp 
        result[30:23] = result_exp_div;

        if (exp_a > 127 && exp_b > 127 && result_exp_div < 127)  begin // overflow
            overflow = 1;              
        end else if (exp_a < 127 && exp_b < 127 && result_exp_div > 127) begin // underflow
            underflow = 1;
        end

    end

end
    
endmodule