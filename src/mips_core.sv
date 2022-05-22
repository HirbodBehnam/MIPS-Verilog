`include "src/adder.sv"
`include "src/sign_extend.sv"
`include "src/alu.sv"
`include "src/control_unit.sv"
`include "323src/regfile.sv"

module mips_core(
	inst_addr,
	inst,
	mem_addr,
	mem_data_out,
	mem_data_in,
	mem_write_en,
	halted,
	clk,
	rst_b
);
input   [31:0] inst;
input   [7:0]  mem_data_out[0:3];
input          clk;
input          rst_b;
output  [31:0] inst_addr;
output  [31:0] mem_addr;
output  [7:0]  mem_data_in[0:3];
output         mem_write_en;
output         halted;

//internal wires

//alu wires
wire [31:0] a_a;
wire [31:0] a_b;
wire [31:0] a_out;
wire a_z;
wire a_n;
wire a_c;

// control wires
wire c_RegDst;
wire c_Jump;
wire c_Branch;
wire c_MemRead;
wire c_MemToReg;
wire [4:0] c_ALUOp;
wire c_MemWrite;
wire c_ALUsrc;
wire c_regWrite;
wire c_Link;
wire c_JumpReg;
wire c_PcOrMem;

//regfile wires
wire r_writereg;
wire r_writedata;
wire r_read1;
wire r_read2;

//misc
wire [31:0] write_buffer;
wire [31:0] ext_15_0;
wire [31:0] pc_load;
wire [31:0] rs1;
wire [31:0] rs2; // jump address
wire [31:0] rs3;
wire [27:0] rs4;
wire [31:0] rs5;
// registers

reg [31:0] pc;

//instantiation
ALU al(.opt(c_ALUOp),.a(r_read1),.b(a_b),.out(a_out),.zero(a_z),.negative(a_n),.carry(a_c));

CU ct(.opcode(inst[31:26]), .func(inst[5:0]), .RegDest(c_RegDst), .Jump(c_Jump), .Branch(c_Branch), 
	.MemToReg(c_MemToReg), .ALUOp(c_ALUOp), .MemWrite(mem_write_en), .JumpReg(c_JumpReg),
	.ALUsrc(c_ALUsrc), .RegWrite(c_regWrite), .Link(c_Link));

regfile rr(.rs_num(inst[25:21]),.rt_num(inst[20:16]),.rd_num(r_writereg),.rd_data(r_writedata),
	.rd_we(c_regWrite), .clk(clk), .rst_b(rst_b), .halted(halted), .rs_data(r_read1), 
	.rt_data(r_read2));

sign_extend s1(inst[15:0], ext_15_0);

adder a1(.res(rs3), .a(rs1), .b(rs5));

//data flow


assign write_buffer = {mem_data_out[0],mem_data_out[1],mem_data_out[2],mem_data_out[3]};
assign r_writereg = c_regDst ? inst[15:11] : inst[20:16];
assign r_writedata = c_MemToReg ? write_buffer : a_out;

assign a_b = c_ALUSrc ? ext_15_0 : r_read2;

assign {mem_data_out[0],mem_data_out[0],mem_data_out[0],mem_data_out[0]} = r_read2;
assign mem_addr = a_out;

assign rs1 = pc + 4;
assign rs2 = {rs1[31:28],rs4};

assign rs4 = inst[27:0] <<2;
assign rs5 = ext_15_0<<2;


assign pc_load = ( c_Jump ? rs2 : ( (c_Branch & a_z) ? rs3 : rs1) );


assign halted = inst[31:26] == 6'b001100;

// behavioral
always @(posedge clk) begin
	pc = pc_load;
end

endmodule
