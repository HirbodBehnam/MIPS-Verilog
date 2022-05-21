`include "src/control_unit_macros.sv"
`include "src/alu_opts.sv"

module CU(
    input wire [5:0] opcode,
    input wire [5:0] func,
    output reg RegDest,
    output reg Link,
    output reg Jump,
    output reg JumpReg,
    output reg Branch,
    output reg MemToReg,
    output reg PCorMemALU,
    output reg [5:0] ALUOp,
    output reg MemWrite,
    output reg MemRead,
    output reg ALUsrc,
    output reg RegWrite,
    output reg jalCtrl,
    output reg jrCtrl
);

    casez (opcode)
        // R type opts
        R_TYPE: 
            case (func)
                :
                default:
            endcase    
        // J type opts
        J_TYPE:
            case (opcode)
                J: begin
                    Jump = 1'b1;
                    {RegWrite, MemToReg, MemWrite, MemRead} = 4'b0000;
                end

                JAL: begin
                    {RegWrite, Link, Jump} = 3'b111;
                    {PCorMemALU, MemRead, MemWrite, JumpReg} = 4'b0000;
                end
            endcase

        // I type opts
        default:
            case (opcode)
                ADDi: begin
                    {ALUsrc, PCorMemALU, RegWrite} = 3'b111;
                    {RegDest, MemToReg, Link, MemRead, MemWrite, Jump} = 6'b000000;
                    {ALUOp} = ALU_ADD;
                end

                ADDiu: begin // similar to 'ADDi' in control signals
                    {ALUsrc, PCorMemALU, RegWrite} = 3'b111;
                    {RegDest, MemToReg, Link, MemRead, MemWrite, Jump} = 6'b000000;
                    {ALUOp} = ALU_ADD;
                end

                ANDi: begin
                    {ALUsrc, PCorMemALU, RegWrite} = 3'b111;
                    {RegDest, MemToReg, Link, MemRead, MemWrite, Jump} = 6'b000000;
                    {ALUOp} = ALU_AND;
                end

                XORi: begin 
                    {ALUsrc, PCorMemALU, RegWrite} = 3'b111;
                    {RegDest, MemToReg, Link, MemRead, MemWrite, Jump} = 6'b000000;
                    {ALUOp} = ALU_XOR;
                end

                ORi: begin
                    {ALUsrc, PCorMemALU, RegWrite} = 3'b111;
                    {RegDest, MemToReg, Link, MemRead, MemWrite, Jump} = 6'b000000;
                    {ALUOp} = ALU_OR;
                end

                BEQ: begin
                    {Branch} = 1'b1;
                    {ALUsrc, RegWrite, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = ALU_COMP_NEQ; // "out" in ALU is 0 then "zero" flag is 1
                end 

                BNE: begin 
                    {Branch} = 1'b1;
                    {ALUsrc, RegWrite, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = ALU_COMP_EQ; // "out" in ALU is 0 then "zero" flag is 1
                end 

                BLEZ: begin
                    {Branch} = 1'b1;
                    {ALUsrc, RegWrite, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = ALU_COMP_GT; // "out" in ALU is 0 then "zero" flag is 1
                end

                BGTZ: begin
                    {Branch} = 1'b1;
                    {ALUsrc, RegWrite, MemRead, MemWrite, Jump} = 5'b00000;
                    {ALUOp} = ALU_COMP_LT; // "out" in ALU is 0 then "zero" flag is 1
                end

                LW: begin
                    {ALUsrc, PCorMemALU, RegWrite, MemRead, MemToReg} = 5'b11111;
                    {Jump, Link, RegDest, MemWrite} = 4'b0000;
                    {ALUOp} = ALU_ADD;
                end

                SW: begin
                    {ALUsrc, MemWrite} = 2'b11;
                    {Jump, RegWrite, MemRead, RegDest} = 5'b00000;
                    {ALUOp} = ALU_ADD;
                end

                LB: begin

                end

                SB: begin 

                end
            endcase

    endcase
endmodule