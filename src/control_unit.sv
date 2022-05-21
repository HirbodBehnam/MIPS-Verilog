`include "src/control_unit_macros.sv"

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

                end

                ADDiu: begin 

                end

                ANDi: begin

                end

                XORi: begin 

                end

                ORi: begin

                end

                BEQ: begin

                end 

                BNE: begin 

                end 

                BLEZ: begin

                end

                BGTZ: begin

                end

                LW: begin

                end

                SW: begin

                end

                LB: begin

                end

                SB: begin 

                end
            endcase

    endcase
endmodule