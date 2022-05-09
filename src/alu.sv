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

    // Set simple flags
    assign zero = out == 0;
    assign negative = out[31] == 1;
    
    // Carry is from https://github.com/jmahler/mips-cpu/blob/8e810a3dd2c97a06cb590747517afb0314b3f7ce/alu.v#L25

    // The operation itself
    always_comb begin
        carry = 0; // clear carry at first
        case (opt)
            // Simple math arithmetic
            4'b0000: begin // add
                out = a + b;
                carry = (a[31] == b[31] && out[31] != a[31]) ? 1 : 0;
            end
            4'b0001: begin
                out = a - b; // subtract
                carry = (a[31] == b[31] && out[31] != a[31]) ? 1 : 0;
            end
            4'b0010: out = a * b; // mult
            4'b0011: out = a / b; // div
            // Bit operations
            4'b0100: out = a ^ b;  // xor
            4'b0101: out = a & b;  // and
            4'b0110: out = a | b;  // or
            4'b0111: out = a ~| b; // nor
            // Shift operations
            4'b1000: out = a << b;  // unsigned shift
            4'b1001: out = a >> b;  // unsigned shift
            4'b1010: out = a <<< b; // signed shift
            4'b1011: out = a >>> b; // signed shift
            // Comparition
            4'b1100: out = a > b ? 1 : 0;
            4'b1101: out = a < b ? 1 : 0;
            4'b1110: out = a >= b ? 1 : 0;
            4'b1111: out = a <= b ? 1 : 0;
            default: out = 0;
        endcase
    end

endmodule