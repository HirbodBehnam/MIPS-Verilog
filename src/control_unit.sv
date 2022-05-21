`include "src/control_unit_macros.sv"

module CU(
    input wire [5:0] opcode,
    input wire [5:0] func,
    output reg RegDest,
    output reg Jump,
    output reg Branch,
    output reg MemToReg,
    output reg [5:0] ALUOp,
    output reg MemWrite,
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
                : 
                default: 
            endcase

        // I type opts
        default:
            case (opcode)
                : 
                default: 
            endcase

    endcase
endmodule