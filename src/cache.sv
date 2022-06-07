module Cache(
    input wire clk,
    input wire reset,
    input wire [31:0] mem_addr, // the adderss to read/write
    input wire [7:0] data_in [0:3], // the data which we want to write in cache
    input wire [7:0] mem_data_out [0:3], // connected to memory data ouput
    input wire byte_mode, // should we write/read byte?
    input wire write_enable, // should we write?
    input wire enable, // do we anything to do with cache and memory?
    output reg [7:0] data_out [0:3], // data read or the data which must be written to
    output reg [31:0] output_mem_addr, // must be here because our cache is write back! or we want to read other words for block
    output reg mem_write_en, // should we enable the memory write
    output reg ready // is data_out ready?
    );
   

    // TODO: IMPLEMENT cache with 2048 x 1 word blocks
    // always at clock:
    	// if(enable):
		// take block mem_addr[12:2]
		// check tag(3 bits) and valid bit
		// // addr = mem_addr = 0000000000000000|_3_|____11_____|_2_
		// //                  zero(memory size) tag    block    byte
		// if(miss):
			// if(dirty):
				// write back
			// output_mem_addr = mem_addr
			// wait for sufficient time to read from memory
			// set output
		// if(write_enable):
			// manipulate cahce data
			// set dirty bit
		// else:
			// write output data

	reg [7:0] cache_mem [8191:0];
	reg [3:0] clk_counter;
	reg valid [2047:0];
	reg dirty [2047:0];
	reg [2:0] tag[2047:0];

	reg [2:0] curr_tag;
	reg [10:0] curr_block;
	reg [1:0] curr_byte;


	reg wait_flag_read;
	reg wait_flag_write;

//	reg [7:0] cache_buffer [0:3];

	

	reg state[2:0];
	always @(posedge clk or negedge reset) begin
		{curr_tag, curr_block, curr_byte} = mem_addr[15:0];
		if(~reset) begin
			for(integer i=0;i<2048;i++) begin
				cache_mem[4*i+0] = 0;
				cache_mem[4*i+1] = 0;
				cache_mem[4*i+2] = 0;
				cache_mem[4*i+3] = 0;
				valid[i]=0;
				tag[i] =0;
				dirty[i] =0;
			end
			$display("===cache reset");
			clk_counter=0;
			wait_flag_read =0;
			wait_flag_write = 0;
		end else begin
			if(enable) begin
				if( wait_flag_read || wait_flag_write || !( (curr_tag == tag[curr_block]) && valid[curr_block] ) ) begin // miss -> [write back]? -> fetch from memory
					ready = 0;
					$display("===miss occured");
					$display("%b",wait_flag_read);
					$display("%b",wait_flag_write);
					$display("%h",mem_addr);
					$display("%d",clk_counter);
					//write back i f dirty
					if(dirty[curr_block]) begin
						if(~wait_flag_write) begin
							output_mem_addr = {16'b0,tag[curr_block],curr_block,2'b00};
							data_out[0] = cache_mem[{curr_block,2'b00}];	
							data_out[1] = cache_mem[{curr_block,2'b01}];	
							data_out[2] = cache_mem[{curr_block,2'b10}];	
							data_out[3] = cache_mem[{curr_block,2'b11}];	
							wait_flag_write = 1;
							clk_counter = 4;
							if(~mem_write_en) begin
								mem_write_en = 1;
								clk_counter = 8;
							end
						end else begin
							if(|clk_counter)
								clk_counter=  clk_counter -1;
							else begin
								wait_flag_write = 0;
								dirty[curr_block] = 0;
							end
						end


					end else if(~wait_flag_write) begin
						if(~wait_flag_read) begin
							output_mem_addr = mem_addr;
							clk_counter = 4;
							wait_flag_write = 1;
							if(mem_write_en) begin
								mem_write_en = 0;
								clk_counter = 8;
							end
						end
					end else begin
						if(|clk_counter)
							clk_counter = clk_counter -1;
						else begin
							cache_mem[{curr_block, 2'b00}] = mem_data_out[0];
							cache_mem[{curr_block, 2'b01}] = mem_data_out[1];
							cache_mem[{curr_block, 2'b10}] = mem_data_out[2];
							cache_mem[{curr_block, 2'b11}] = mem_data_out[3];

							tag[curr_block] = curr_tag;
							valid[curr_block] = 1;
							dirty[curr_block] = 0;

							ready =1;
							wait_flag_read = 0;
						end
					end
				end
				if(~wait_flag_write && ~wait_flag_read && write_enable) begin
					$display("===hit occured");
					$display("writing to cache");
					if(byte_mode) begin
						cache_mem[{curr_block, curr_byte}] = data_in[0];
					end else begin
						cache_mem[{curr_block, 2'b00}] = data_in[0];
						cache_mem[{curr_block, 2'b01}] = data_in[1];
						cache_mem[{curr_block, 2'b10}] = data_in[2];
						cache_mem[{curr_block, 2'b11}] = data_in[3];
					end

				end else if(~wait_flag_write && ~wait_flag_read) begin	
					$display("===hit occured");
					$display("reading from cache");
					// write to output
					//						data_out= cache_buffer;
					if(byte_mode) begin
						data_out[0] = cache_mem[{curr_block, curr_byte}];
						if(data_out[0][7]) begin
							data_out[1] = 8'b1;
							data_out[2] = 8'b1;
							data_out[3] = 8'b1;
						end else begin
							data_out[1] = 8'b0;
							data_out[2] = 8'b0;
							data_out[3] = 8'b0;
						end
					end else begin
						data_out[0] = cache_mem[{curr_block, 2'b00}];
						data_out[1] = cache_mem[{curr_block, 2'b01}];
						data_out[2] = cache_mem[{curr_block, 2'b10}];
						data_out[3] = cache_mem[{curr_block, 2'b11}];
					end
				end
			end
		end
	end
	endmodule


