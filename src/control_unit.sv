`include "src/control_unit_macros.sv"
`include "src/alu_opts.sv"

module CU(
    input wire [5:0] opcode,
    input wire [5:0] func,
    input wire rst_b,
    output reg RegDest, // ok
    output reg Jump, // ok
    output reg JumpReg, // ok
    output reg Branch, // ok
    output reg MemToReg, // ok
    output wire Link, // ok
    output reg [4:0] ALUOp, // ok
    output reg MemWrite, // ok
    output reg ALUsrc, // ok 
    output reg MemRead, // ok 
    output reg RegWrite, // ok
    output reg Halted,
    output reg SignExtend,
    output reg MemByte,
    // Added for phase 4
    output reg FloatingPointWriteEnable,
    output reg FPUorALU,
    output reg [3:0] FPUOpcode
);
    reg NotLink;
    assign Link = ~NotLink;

    always @(*) begin
    {ALUsrc, Jump, JumpReg, Branch, MemRead, MemToReg, MemWrite, RegDest, RegWrite, NotLink, SignExtend, MemByte, Halted} = 0;
    {FloatingPointWriteEnable, FPUorALU, FPUOpcode} = 0;
	if(~rst_b)
	begin
		Halted = 0;
		SignExtend = 1;
	end
	else
        casez (opcode)
        // R type opts
        `R_TYPE: begin
            case (func)
                `XOR:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_XOR;
                    end
                `SLL:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_UNSIGNED_SHIFT_LEFT_SH_AMOUNT;
                    end
                `SLLV:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_UNSIGNED_SHIFT_LEFT;
                    end
                `SRL:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_UNSIGNED_SHIFT_RIGHT_SH_AMOUNT;
                    end
                `SUB:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_SUB;
                    end
                `SRLV:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_UNSIGNED_SHIFT_RIGHT;
                    end
                `SLT:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_COMP_LT;
                    end
                `SUBU:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_SUB;
                    end
                `OR:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_OR;
                    end
                `NOR:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_NOR;
                    end
                `ADDU:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_ADD;
                    end
                `MULT:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_MULT;
                    end
                `DIV:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_DIV;
                    end
                `AND:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_AND;
                    end
                `ADD:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_ADD;
                    end
                `SRA:begin
                    {RegDest,NotLink,RegWrite}=3'b111;
                    {ALUOp} = `ALU_SIGNED_SHIFT_RIGHT_SH_AMOUNT;
                    end
                `JR:begin
                    {Jump, JumpReg} = 2'b11;
                    end
                `FPU_ADD:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b0000;
                end

                `FPU_SUB:begin
                    FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b0001;
                end

                `FPU_MULT:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b0010;
                end

                `FPU_DIV:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b0011;                    
                end

                `FPU_NEGATE:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b0100;                    
                end

                `FPU_ROUND:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b0101;                    
                end

                `FPU_FLOAT_TO_BINARY:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b0110;                    
                end

                `FPU_BINARY_TO_FLOAT:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b0111;                    
                end

                `FPU_COMP_LT:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b1000;                    
                end

                `FPU_COMP_LE:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b1001;                    
                end

                `FPU_COMP_EQ:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b1010;                    
                end

                `FPU_COMP_NQ:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b1011;                    
                end

                `FPU_COMP_GT:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b1100;                    
                end

                `FPU_COMP_GE:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b1101;                    
                end

                `FPU_MOVE_TO_FLOAT:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b11;
                    FPUOpcode = 4'b1110;                    
                end

                `FPU_MOVE_FROM_FLOAT:begin
                    {FloatingPointWriteEnable, FPUorALU} = 2'b01;
                    FPUOpcode = 4'b1111;                    
                end
        
                default:begin
                    $display("UNKNOWN FUNC: %b", func);
                    Halted = 1'b1;
                    end
            endcase
        end 
        // J type opts
        `J_TYPE:
            case (opcode)
                `J: begin
                    Jump = 1'b1;
                end

                `JAL: begin
                    {RegWrite, Jump} = 2'b11;
                end
		default:begin
		end
            endcase

        // I type opts
        default:
            case (opcode)
                `ADDi: begin
                    {ALUsrc, NotLink, RegWrite} = 3'b111;
                    {ALUOp} = `ALU_ADD;
		            SignExtend = 1;
                end

                `ADDiu: begin // similar to 'ADDi' in control signals
                    {ALUsrc, NotLink, RegWrite} = 3'b111;
                    {ALUOp} = `ALU_ADD;
                end

                `ANDi: begin	// DO NOT EXTEND SIGN
                    {ALUsrc, NotLink, RegWrite} = 3'b111;
                    {ALUOp} = `ALU_AND;
                end

                `XORi: begin 	// DO NOT EXTEND SIGN
                    {ALUsrc, NotLink, RegWrite} = 3'b111;
                    {ALUOp} = `ALU_XOR;
                end

                `ORi: begin	// DO NOT EXTEND SIGN
                    {ALUsrc, NotLink, RegWrite} = 3'b111;
                    {ALUOp} = `ALU_OR;
		      
                end

                `BEQ: begin
                    {Branch} = 1'b1;
                    {ALUOp} = `ALU_COMP_NEQ; // "out" in ALU is 0 then "zero" flag is 1
		            SignExtend = 1;
                end 

                `BNE: begin 
                    {Branch} = 1'b1;
                    {ALUOp} = `ALU_COMP_EQ; // "out" in ALU is 0 then "zero" flag is 1
		            SignExtend = 1;
                end 

                `BLEZ: begin
                    {Branch} = 1'b1;
                    {ALUOp} = `ALU_COMP_GT; // "out" in ALU is 0 then "zero" flag is 1
		            SignExtend = 1;
                end

                `BGTZ: begin
                    {Branch} = 1'b1;
                    {ALUOp} = `ALU_COMP_LT; // "out" in ALU is 0 then "zero" flag is 1
		            SignExtend = 1;
                end

                `LW: begin
                    {ALUsrc, NotLink, RegWrite, MemRead, MemToReg} = 5'b11111;
                    {ALUOp} = `ALU_ADD;
		            SignExtend = 1;
                end

                `SW: begin
                    {ALUsrc, MemWrite} = 2'b11;
                    {ALUOp} = `ALU_ADD;
		            SignExtend = 1;
                end

                `LB: begin
                    {ALUsrc, NotLink, RegWrite, MemRead, MemToReg, MemByte} = 6'b111111;
                    {ALUOp} = `ALU_ADD;
		            SignExtend = 1;
                end

                `SB: begin
                    {ALUsrc, MemWrite, MemByte} = 3'b111;
                    {ALUOp} = `ALU_ADD;
		            SignExtend = 1;
                end

                `SLTi: begin
                    {ALUsrc, NotLink, RegWrite} = 3'b111;
                    {ALUOp} = `ALU_COMP_LT;
		            SignExtend = 1;
                end

                `LUI: begin
                    {ALUsrc, NotLink, RegWrite} = 3'b111;
                    {ALUOp} = `ALU_LUI;
                    SignExtend = 1;
                end
		default: begin
            $display("UNKOWN OPCODE: %b", opcode);
		end

                // LB and SB cases were deleted 
            endcase
        endcase
    end
endmodule
