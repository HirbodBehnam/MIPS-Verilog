//`include "src/alu.sv"

// Run with iverilog alu_TB.sv && ./a.out

module ALU_Testbench;
    reg [31:0] a, b, out_expected;
    reg [4:0] opt;
    wire zero, carry, negative;
    wire [31:0] out;
    ALU alu(.opt(opt), .a(a), .b(b), .out(out), .zero(zero), .carry(carry), .negative(negative));

    initial begin
        a = 1234;
        b = 4321;
        opt = `ALU_ADD;
        out_expected = a + b;
        #10;
        $display("%d +   %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(b), $signed(out), $signed(out_expected), carry, zero, negative);
        #10;
        opt = `ALU_SUB;
        out_expected = a - b;
        #10;
        $display("%d -   %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(b), $signed(out), $signed(out_expected), carry, zero, negative);
        #10;
        a = -2147483647;
        b = 2;
        out_expected = a - b;
        #10;
        $display("%d -   %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(b), $signed(out), $signed(out_expected), carry, zero, negative);
        #10;
        a = 12;
        b = -34;
        out_expected = a * b;
        opt = `ALU_MULT;
        #10;
        $display("%d *   %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(b), $signed(out), $signed(out_expected), carry, zero, negative);
        #10;
        a = 12;
        b = -34;
        out_expected = 1;
        opt = `ALU_COMP_GE;
        #10;
        $display("%d >   %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(b), $signed(out), $signed(out_expected), carry, zero, negative);
        #10
        a = 0;
        b = 32'b1010101;
        out_expected = 32'b1010101_0000_0000_0000_0000;
        opt = `ALU_LUI;
        #10;
        $display("%d u   %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(b), $signed(out), $signed(out_expected), carry, zero, negative);
        #10;
        a = -1;
        b = 30;
        out_expected = 3;
        opt = `ALU_UNSIGNED_SHIFT_RIGHT;
        #10;
        $display("%d >>  %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(b), $signed(out), $signed(out_expected), carry, zero, negative);
        #10;
        a = -1;
        b = 30;
        out_expected = {2'b11, {30{1'b0}}};
        opt = `ALU_UNSIGNED_SHIFT_LEFT;
        #10;
        $display("%d <<  %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(b), $signed(out), $signed(out_expected), carry, zero, negative);
        a = -1;
        b = {21'b0, 5'd30, 6'b0};
        out_expected = 3;
        opt = `ALU_UNSIGNED_SHIFT_RIGHT_SH_AMOUNT;
        #10;
        $display("%d >>  %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(30), $signed(out), $signed(out_expected), carry, zero, negative);
        #10;
        a = -1;
        b = {21'b0, 5'd30, 6'b0};
        out_expected = -1;
        opt = `ALU_SIGNED_SHIFT_RIGHT_SH_AMOUNT;
        #10;
        $display("%d >>> %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(30), $signed(out), $signed(out_expected), carry, zero, negative);
        #10;
        a = -1;
        b = {21'b0, 5'd30, 6'b0};
        out_expected = {2'b11, {30{1'b0}}};;
        opt = `ALU_SIGNED_SHIFT_LEFT_SH_AMOUNT;
        #10;
        $display("%d <<< %d = %d (%d) | carry = %d zero = %d negative = %d", $signed(a), $signed(30), $signed(out), $signed(out_expected), carry, zero, negative);
        $finish;
    end
endmodule
