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
wire [31:0] a_immidate_or_reg_data;
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
// cache control and multi cycle
wire cache_ready;
wire [7:0] cache_data_out [0:3];
assign mem_data_in = cache_data_out;
wire [7:0] cache_data_in [0:3];
assign {cache_data_in[0], cache_data_in[1], cache_data_in[2], cache_data_in[3]} = exmem_register_data_2;
wire cache_enable = exmem_memread | exmem_memwrite; // Enable cache if there is a read or write
wire stall = cache_enable & (~cache_ready); // Stall if we are reading from memory and the data is not ready
//pipeline registers
reg[31:0] ifid_instruction;
reg[31:0] ifid_pcp4;
reg[31:0] idex_register_data_1;
reg[31:0] idex_register_data_2;
reg[4:0] idex_writeregister;
reg[31:0] idex_signextend; 
reg idex_cjump;
reg idex_cjump_reg;
reg idex_cbranch;
reg idex_cmemtoreg;
reg[4:0] idex_aluop;
reg idex_regwrite;
reg idex_memread;
reg idex_membyte;
reg idex_memwrite;
reg idex_ALU_src;
reg idex_link;
reg idex_halted;
reg[31:0] idex_pc;
reg[31:0] idex_instruction;
reg[4:0] exmem_writeregister;
reg exmem_regwrite;
reg exmem_cjump;
reg exmem_cjump_reg;
reg exmem_cbranch;
reg exmem_memtoreg;
reg[31:0] exmem_pc;
reg exmem_memread;
reg exmem_membyte;
reg exmem_memwrite;
reg exmem_zero;
reg[31:0] exmem_register_data_1;
reg[31:0] exmem_register_data_2;
reg[31:0] exmem_alu_result;
reg[31:0] exmem_instruction;
reg exmem_link;
reg exmem_halted;
reg[4:0] memwb_writeregister;
reg[31:0] memwb_memory_read_data;
reg[31:0] memwb_pc;
reg memwb_regwrite;
reg memwb_memtoreg;
reg[31:0] memwb_alu_result;
reg memwb_halted;
reg memwb_link;

//instantiation
ALU al(
	.opt(idex_aluop),
	.a(idex_register_data_1),
	.b(a_immidate_or_reg_data),
	.shamt(idex_instruction[10:6]),
	.out(a_out),
	.zero(a_z),
	.negative(a_n),
	.carry(a_c)
);

CU ct(
	.opcode(ifid_instruction[31:26]),
	.func(ifid_instruction[5:0]),
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

regfile rr(
	.rs_num(ifid_instruction[25:21]),
	.rt_num(ifid_instruction[20:16]),
	.rd_num(memwb_writeregister),
	.rd_data(r_writedata), // this one is a wire
	.rd_we(memwb_regwrite),
	.clk(clk),
	.rst_b(rst_b),
	.halted(halted),
	.rs_data(r_read1),
	.rt_data(r_read2)
);

//always @(*)
//	$display("%d <- %d o %d | %d", r_writereg1, inst[25:21], inst[20:16], r_writedata);


sign_extend s1(ifid_instruction[15:0], ext_15_0, c_SignExtend);

Cache cache(
	.clk(clk),
	.reset(rst_b),
	.mem_addr(exmem_alu_result), // memory address is conected to alu
	.data_in(cache_data_in), // connected to second register file output
	.mem_data_out(mem_data_out), // connect to memory data output
	.byte_mode(exmem_membyte), // control unit says it
	.write_enable(exmem_memwrite), // same as above, control unit thing
	.enable(cache_enable), // either we must be writing or reading memory
	.data_out(cache_data_out), // can be either memory write data or memory read data
	.output_mem_addr(mem_addr), // is here for write or read of other words in block
	.mem_write_en(mem_write_en), // cache enables the write
	.ready(cache_ready) // ready to fetch the next instruction
);

//data flow  

assign r_writereg1 = c_Link ? (c_RegDst ? ifid_instruction[15:11] : ifid_instruction[20:16]) : 5'd31; // Done in register file stage

assign r_writedata = memwb_link ?
					(memwb_memtoreg ? memwb_memory_read_data : memwb_alu_result)
					: memwb_pc; // Done in write back

assign a_immidate_or_reg_data = idex_ALU_src ? idex_signextend : idex_register_data_2;

assign halted = memwb_halted;

// All of this must be done in mem phase
assign inst_addr_load = exmem_cjump_reg ? // jr
						exmem_register_data_1 :
						(
							exmem_cjump ? // j and jal
							{exmem_pc[31:28], exmem_instruction[27:0] << 2} :
							(
								(exmem_cbranch & exmem_zero) ? // branch
								exmem_pc + (ext_15_0 << 2) :
								// Note to myself: We are always running this in each block.
								// So this must get the current pc counter
								inst_addr + 4
							)
						);

// behavioral
always @(posedge clk or negedge rst_b) begin
	if (rst_b == 0) begin
		inst_addr <= -4;
		//$display("RESET");
	end else begin
		if (!stall) begin
			//$display("got %b on %d", inst, inst_addr / 4);
			// Load the next struction address
			inst_addr <= inst_addr_load;
			// Instruction fetch. Only instruction and pc + 4 are needed
			ifid_instruction <= inst;
			ifid_pcp4 <= inst_addr + 4;
			// After register file. Includes the registers and control unit signals
			idex_register_data_1 <= r_read1; // First register output
			idex_register_data_2 <= r_read2; // Second register output
			idex_signextend <= ext_15_0; // Sign extend result
			idex_cjump <= c_Jump; // Is this jump? Will be needed until Mem
			idex_cjump_reg <= c_JumpReg; // Enabled on jal instruction. Will be used in mem
			idex_cbranch <= c_Branch; // Is this branch? Will be needed until Mem
			idex_cmemtoreg <= c_MemToReg; // Should we write the memory data into registers? Goes until end
			idex_aluop <= c_ALUOp; // ALU operation. Goes until execute
			idex_regwrite <= c_regWrite; // Write enable of register file. Goes until very end
			idex_memread <= c_MemRead; // Should we read from memory? Goes until memory
			idex_membyte <= c_MemByte; // Is this a byte read? Goes unitl memory
			idex_memwrite <= c_MemWrite; // Should we write to memory? Goes until memory
			idex_ALU_src <= c_ALUsrc; // Should ALU use the immidate or the register?
			idex_pc <= ifid_pcp4; // From last step. The PC + 4
			idex_writeregister <= r_writereg1; // The register number which data should be written to. Goes until end
			idex_instruction <= ifid_instruction; // The instruction itself
			idex_halted <= c_halted; // We must halt after we have written to registers
			idex_link <= c_Link; // True if we want to jal. Goes until memory
			// After Execute (ALU)
			exmem_regwrite <= idex_regwrite; // The write enable which must go until end
			exmem_cjump <= idex_cjump; // Should we jump? This is the last one
			exmem_cbranch <= idex_cbranch; // Should we branch if needed? This is the last step
			exmem_memtoreg <= idex_cmemtoreg; // Should we write memory into registers? Goes until next stage
			exmem_cjump_reg <= idex_cjump_reg; // Should we jump to register? (jr)
			exmem_pc <= idex_pc; // The program counter of the command which is being executed
			exmem_memread <= idex_memread; // Should we read from memory?
			exmem_membyte <= idex_membyte; // Should we read/write byte?
			exmem_memwrite <= idex_memwrite; // Should we write to memory?
			exmem_register_data_1 <= idex_register_data_1; // Needed for jr in next 
			exmem_register_data_2 <= idex_register_data_2; // Needed for data to be written to memory
 			exmem_zero <= a_z; // Is the alu result zero?
			exmem_alu_result <= a_out; // The result of alu
			exmem_link <= idex_link; // Link used in jal
			exmem_writeregister <= idex_writeregister; // Number of register to write in
			exmem_instruction <= idex_instruction; // The instruction itself
			exmem_halted <= idex_halted; // Halt at last
			// Memory phase (last one)
			memwb_memory_read_data <= {cache_data_out[0], cache_data_out[1], cache_data_out[2], cache_data_out[3]}; // Mem out
			memwb_regwrite <= exmem_regwrite; // Write enable of register file
			memwb_writeregister <= exmem_writeregister; // The register to write into
			memwb_alu_result <= exmem_alu_result; // The alu result if this is write back
			memwb_pc <= exmem_pc; // The program counter because we might write back to register
			memwb_memtoreg <= exmem_memtoreg; // Should memory data go to register or alu
			memwb_halted <= exmem_halted; // Halt the system if needed
			memwb_link <= exmem_link; // If link is true the pc will go to register
		end
	end
end

endmodule
// TODO: fix link