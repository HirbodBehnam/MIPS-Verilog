
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
output reg     halted;

//internal wires

//alu wires
wire [4:0] a_opt;
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
wire [5:0] c_ALUOp;
wire c_MemWrite;
wire c_ALUsrc;
wire c_regWrite;
wire c_jalCtrl;
wire c_jrCtrl;

//regfile wires
wire r_writereg;
wire r_writedata;
wire r_read1;
wire r_read2;

//misc
wire [31:0] write_buffer;
wire [31:0] ext_15_0;


//instantiation
ALU al(.opt(a_opt),.a(r_read1),.b(a_b),.out(a_out),.zero(a_z),.negative(a_n),.carry(a_c);

Control ct(.opcode(inst[31:26]), c_RegDst, c_Jump, c_Branch, 
	c_MemToReg, c_ALUOp, mem_write_en, 
	c_ALUsrc, c_regWrite,c_jalCtrl, c_jrCtrl);

ALUControl alc(.opcode(c_ALUop), .func(inst[5:0]),.inst(a_opt));

regfile rr(.rs_num(inst[25:21]),.rt_num(inst[20:16]),.rd_num(r_writereg),.rd_data(r_writedata),
	.rd_we(c_regWrite), .clk(clk), .rst_b(rst_b), .halted(halted), .rs_data(r_read1), 
	.rt_data(r_read2));

sign_extend s1(inst[15:0], ext_15_0);

//data flow
assign write_buffer = {mem_data_out[0],mem_data_out[1],mem_data_out[2],mem_data_out[3]};
assign r_writereg = c_regDst ? inst[15:11] : inst[20:16];
assign r_writedata = c_MemToReg ? write_buffer : a_out;

assign a_b = c_ALUSrc ? ext_15_0 : r_read2;

assign {mem_data_out[0],mem_data_out[0],mem_data_out[0],mem_data_out[0]} = r_read2;
assign mem_addr = a_out;

endmodule
