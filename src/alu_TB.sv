`include "alu.sv"

// Run with iverilog alu_TB.sv && ./a.out

module ALU_Testbench;
    reg [31:0] a, b, out_expected;
    reg [3:0] opt;
    wire zero, carry, negative;
    wire [31:0] out;
    ALU alu(.opt(opt), .a(a), .b(b), .out(out), .zero(zero), .carry(carry), .negative(negative));

    initial begin
        a = 1234;
        b = 4321;
        opt = `ALU_ADD;
        out_expected = a + b;
        #10;
        $display("%d + %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(b), $signed(out), $signed(out_expected), carry, zero, negative);
        #10;
        opt = `ALU_SUB;
        out_expected = a - b;
        #10;
        $display("%d - %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(b), $signed(out), $signed(out_expected), carry, zero, negative);
        #10;
        a = -2147483647;
        b = 2;
        out_expected = a - b;
        #10;
        $display("%d - %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(b), $signed(out), $signed(out_expected), carry, zero, negative);
        #10;
        a = 12;
        b = -34;
        out_expected = a * b;
        opt = `ALU_MULT;
        #10;
        $display("%d - %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(b), $signed(out), $signed(out_expected), carry, zero, negative);
        $finish;
    end
endmodule