//`include "src/adder.sv"
//`include "src/sign_extend.sv"
//`include "src/alu.sv"
//`include "src/control_unit.sv"
//`include "323src/regfile.sv"
//`include "src/cache.sv"

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
output reg [31:0] inst_addr;
output  [31:0] mem_addr;
output  [7:0]  mem_data_in[0:3];
output         mem_write_en;
output         halted;

//internal wires

//alu wires
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
wire c_SignExtend;
wire c_MemByte;

//regfile wires
wire [4:0] r_writereg1;
wire [4:0] r_writereg2;
wire [31:0] r_writedata;
wire [31:0] r_read1;
wire [31:0] r_read2;

//misc
wire [31:0] write_buffer;
wire [31:0] ext_15_0;
wire [31:0] inst_addr_load;
wire [31:0] rs1;
wire [31:0] rs2; // jump address
wire [31:0] rs3;
wire [27:0] rs4;
wire [31:0] rs5;
// cache control and multi cycle
wire cache_ready;
wire [7:0] cache_data_out [0:3];
assign mem_data_in = cache_data_out;
wire [7:0] cache_data_in [0:3];
assign {cache_data_in[0], cache_data_in[1], cache_data_in[2], cache_data_in[3]} = r_read2;
wire cache_enable = c_MemRead | c_MemWrite;
wire load_next_instruction = ~(c_MemRead | c_MemWrite) | cache_ready;


//instantiation
ALU al(.opt(c_ALUOp),
	.a(r_read1),
	.b(a_b),
	.shamt(inst[10:6]),
	.out(a_out),
	.zero(a_z),
	.negative(a_n),
	.carry(a_c)
);

CU ct(.opcode(inst[31:26]),
	.func(inst[5:0]),
	.RegDest(c_RegDst),
	.Jump(c_Jump),
	.Branch(c_Branch),
	.MemToReg(c_MemToReg),
	.ALUOp(c_ALUOp),
	.MemWrite(c_MemWrite),
	.JumpReg(c_JumpReg),
	.ALUsrc(c_ALUsrc),
	.RegWrite(c_regWrite),
	.Link(c_Link),
	.MemRead(c_MemRead),
	.Halted(halted),
	.rst_b(rst_b),
	.SignExtend(c_SignExtend),
	.MemByte(c_MemByte)
);

regfile rr(.rs_num(inst[25:21]),
	.rt_num(inst[20:16]),
	.rd_num(r_writereg1),
	.rd_data(r_writedata),
	.rd_we(c_regWrite),
	.clk(clk),
	.rst_b(rst_b),
	.halted(halted),
	.rs_data(r_read1),
	.rt_data(r_read2)
);

//always @(*)
//	$display("%d <- %d o %d | %d", r_writereg1, inst[25:21], inst[20:16], r_writedata);


sign_extend s1(inst[15:0], ext_15_0, c_SignExtend);

adder a1(.res(rs3),
	.a(rs1),
	.b(rs5)
);

Cache cache(
	.clk(clk),
	.reset(rst_b),
	.mem_addr(a_out), // memory address is conected to alu
	.data_in(cache_data_in), // connected to second register file output
	.mem_data_out(mem_data_out), // connect to memory data output
	.byte_mode(c_MemByte), // control unit says it
	.write_enable(c_MemWrite), // same as above, control unit thing
	.enable(cache_enable), // either we must be writing or reading memory
	.data_out(cache_data_out), // can be either memory write data or memory read data
	.output_mem_addr(mem_addr), // is here for write or read of other words in block
	.mem_write_en(mem_write_en), // cache enables the write
	.ready(cache_ready) // ready to fetch the next instruction
);

//data flow

assign r_writereg1 = c_Link ? (c_RegDst ? inst[15:11] : inst[20:16]) : 5'd31;

assign r_writedata = c_Link ? (c_MemToReg ? {cache_data_out[0], cache_data_out[1], cache_data_out[2], cache_data_out[3]} : a_out) : rs1;

assign a_b = c_ALUsrc ? ext_15_0 : r_read2;

assign rs1 = inst_addr + 4;
assign rs2 = {rs1[31:28],rs4};

assign rs4 = inst[27:0] <<2;
assign rs5 = ext_15_0<<2;


assign inst_addr_load = c_JumpReg ? r_read1 : ( c_Jump ? rs2 : ( (c_Branch & a_z) ? rs3 : rs1) );


// behavioral
always @(posedge clk or negedge rst_b) begin
	if (rst_b == 0) begin
		inst_addr <= -4;
		//$display("RESET");
	end else begin
		if (load_next_instruction)
			inst_addr <= inst_addr_load;
		//$display("got %b on %d", inst, inst_addr / 4);
	end
end

endmodule
