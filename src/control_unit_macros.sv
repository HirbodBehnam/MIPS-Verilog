`define R_TYPE                  6'b000000
`define J_TYPE                  6'b00001?

// R Type macros
`define XOR                     6'b100110
`define SLL                     6'b000000
`define SLLV                    6'b000100
`define SRL                     6'b000010
`define SUB                     6'b100010
`define SRLV                    6'b000110
`define SLT                     6'b101010
`define Syscall                 6'b001100
`define SUBU                    6'b100011
`define OR                      6'b100101
`define NOR                     6'b100111
`define ADDU                    6'b100001
`define MULT                    6'b011000
`define DIV                     6'b011010
`define AND                     6'b100100
`define ADD                     6'b100000
`define JR                      6'b001000
`define SRA                     6'b000011
`define F_ADD                 6'b000001
`define F_SUB                 6'b000101
`define F_MULT                6'b000111
`define F_DIV                 6'b001001
`define F_NEGATE              6'b001010
`define F_ROUND               6'b001011
`define F_FLOAT_TO_BINARY     6'b001101
`define F_BINARY_TO_FLOAT     6'b001110
`define F_COMP_LT             6'b001111
`define F_COMP_LE             6'b010000
`define F_COMP_EQ             6'b010001
`define F_COMP_NQ             6'b010010
`define F_COMP_GT             6'b010011
`define F_COMP_GE             6'b010100
`define F_MOVE_TO_FLOAT       6'b010101
`define F_MOVE_FROM_FLOAT     6'b010110
// J Type macros
`define J                       6'b000010
`define JAL                     6'b000011


// I Type macros
`define ADDi                    6'b001000
`define ADDiu                   6'b001001
`define ANDi                    6'b001100
`define XORi                    6'b001110
`define ORi                     6'b001101
`define BEQ                     6'b000100
`define BNE                     6'b000101 
`define BLEZ                    6'b000110 
`define BGTZ                    6'b000111 
`define LW                      6'b100011
`define SW                      6'b101011
`define LB                      6'b100000
`define SB                      6'b101000
`define SLTi                    6'b001010 
`define LUI                     6'b001111





