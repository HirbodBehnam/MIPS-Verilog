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
wire c_halted;
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
wire stall = ~(c_MemRead | c_MemWrite) | cache_ready;
//pipeline registers
reg[31:0] ifid_instruction;
reg[31:0] ifid_pcp4 ;
reg[31:0] idex_readdata ;
reg[4:0] idex_writeregister;
reg[31:0] idex_readdata2 ;
reg[31:0] idex_signextend ; 
reg idex_cjump ;
reg idex_cbranch ;
reg idex_cmemtoreg ;
reg[5:0] idex_aluop ;
reg idex_regwrite ;
reg idex_memread ;
reg idex_membyte ;
reg[31:0] idex_pc ;
reg[31:0] idex_instruction ;
reg[4:0] exmem_writeregister ;
reg exmem_regwrite ;
reg exmem_cjump ;
reg exmem_cbranch ;
reg exmem_memtoreg ;
reg[31:0] exmem_pc ;
reg exmem_memread ;
reg exmem_membyte ;
reg exmem_zero ;
reg[31:0] exmem_result ;
reg[31:0] exmem_instruction;
reg[31:0] exmem_immediate;
reg[4:0] memwb_writeregister;
reg[31:0] memwb_readdata ;
reg memwb_regwrite ;
reg memwb_cjump ;
reg memwb_cbranch ;
reg memwb_memtoreg ;
reg memwb_memwrite ;
reg memwb_memread ;
reg memwb_membyte ;
reg[4:0] wb_writeregister ;
reg wb_regwrite ;
reg wb_memtoreg ;
reg[31:0] wb_readdata ;
reg idex_halted ;
reg exmem_halted;
reg memwb_halted;
reg wb_halted;
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
	.Halted(c_halted),
	.rst_b(rst_b),
	.SignExtend(c_SignExtend),
	.MemByte(c_MemByte)
);

regfile rr(.rs_num(inst[25:21]),
	.rt_num(inst[20:16]),
	.rd_num(wb_writeregister),
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
assign halted = wb_halted ;

assign inst_addr_load = c_JumpReg ? r_read1 : ( c_Jump ? rs2 : ( (c_Branch & a_z) ? rs3 : rs1) );

// behavioral
always @(posedge clk or negedge rst_b) begin
	if (rst_b == 0) begin
		inst_addr <= -4;
		//$display("RESET");
	end else begin
		if (!stall)
		//$display("got %b on %d", inst, inst_addr / 4);
		begin
			inst_addr <= inst_addr_load;
			ifid_instruction <= inst;
			ifid_pcp4 <= rs1;
			idex_readdata <= r_read1;
			idex_readdata2 <= r_read2;
			idex_signextend <= ext_15_0; 
			idex_cjump <= c_Jump;
			idex_cbranch <= c_Branch;
			idex_cmemtoreg <= c_MemToReg;
			idex_aluop <= c_ALUOp;
			idex_regwrite <= c_regWrite;
			idex_memread <= c_MemRead; 
			idex_membyte <= c_MemByte;
			idex_pc <= ifid_pcp4;
			idex_writeregister <= r_writereg1;
			idex_instruction <= ifid_instruction;
			exmem_regwrite <= idex_regwrite;
			exmem_cjump <= idex_cjump;
			exmem_cbranch <= idex_cbranch;
			exmem_memtoreg <= idex_cmemtoreg;
			exmem_pc <= idex_pc;
			exmem_memread <= idex_memread;
			exmem_membyte <= idex_membyte;
 			exmem_zero <= zero;
			exmem_result <= result ;
			exmem_immediate <= idex_readdata2;
			exmem_writeregister <= idex_writeregister;
			exmem_instruction <= idex_instruction;
			memwb_readdata <= cache_data_out;
			memwb_regwrite <= exmem_regwrite;
			memwb_cjump <= exmem_cjump;
			memwb_cbranch <= exmem_cbranch;
			memwb_memtoreg <= exmem_cmemtoreg;
			memwb_memwrite <= c_MemWrite;
			memwb_memread <= exmem_memread;
			memwb_membyte <= exmem_membyte;
			memwb_writeregister <= exmem_writeregister;
			wb_regwrite <= memwb_regwrite;
			wb_memtoreg <= memwb_memtoreg;
			wb_readdata <= memwb_readdata;
			wb_writeregister <= memwb_writeregister;
			idex_halted <= c_halted;
			exmem_halted <= idex_halted;
			memwb_halted <= exmem_halted;
			wb_halted <= memwb_halted;
		end
	end
end

endmodule
