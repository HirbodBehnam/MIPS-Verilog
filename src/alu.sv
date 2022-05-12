`include "alu_opts.sv"

module ALU(
    input wire [3:0] opt,
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] out,
    // Is set when out is zero
    output wire zero,
    // Is set when result is negative
    output wire negative,
    // Overflow or underflow
    output reg carry
);

    // Temp value for carry calculation
    reg [31:0] temp;

    // Set simple flags
    assign zero = out == 0;
    assign negative = out[31] == 1;
    
    // Carry from https://electronics.stackexchange.com/a/509341

    // The operation itself
    always @(*) begin
        carry = 0; // clear carry at first
        case (opt)
            // Simple math arithmetic
            `ALU_ADD: begin // add
                out = a + b;
                carry = (a[31]^b[31]) ? 0: (out[31]^a[31]);
            end
            `ALU_SUB: begin
                out = a - b; // subtract
                temp = (~b) + 1;
                carry = (a[31]^temp[31]) ? 0: (out[31]^a[31]);
            end
            `ALU_MULT: out = a * b; // mult
            `ALU_DIV: out = a / b; // div
            // Bit operations
            `ALU_XOR: out = a ^ b;  // xor
            `ALU_AND: out = a & b;  // and
            `ALU_OR: out = a | b;  // or
            `ALU_NOR: out = a ~| b; // nor
            // Shift operations
            `ALU_UNSIGNED_SHIFT_LEFT: out = a << b;  // unsigned shift
            `ALU_UNSIGNED_SHIFT_RIGHT: out = a >> b;  // unsigned shift
            `ALU_SIGNED_SHIFT_LEFT: out = a <<< b; // signed shift
            `ALU_SIGNED_SHIFT_RIGHT: out = a >>> b; // signed shift
            // Comparition
            `ALU_COMP_GT: out = a > b ? 1 : 0;
            `ALU_COMP_LT: out = a < b ? 1 : 0;
            `ALU_COMP_GE: out = a >= b ? 1 : 0;
            `ALU_ADD_LE: out = a <= b ? 1 : 0;
            default: out = 0;
        endcase
    end

endmodule