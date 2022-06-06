module Cache(
    input wire clk,
    input wire reset,
    input wire [31:0] mem_addr, // the adderss to read/write
    input wire [7:0] data_in [0:3], // the data which we want to write in cache
    input wire [7:0] mem_data_out [0:3], // connected to memory data ouput
    input wire byte_mode, // should we write/read byte?
    input wire write_enable, // should we write?
    input wire enable, // do we anything to do with cache and memory?
    output wire [7:0] data_out [0:3], // data read or the data which must be written to
    output wire [31:0] output_mem_addr, // must be here because our cache is write back! or we want to read other words for block
    output wire mem_write_en, // should we enable the memory write
    output wire ready // is data_out ready?
    );
    
    // TODO: IMPLEMENT cache with 2048 x 1 word blocks
    // always at clock:
    	// if(enable):
		// take block mem_addr[12:2]
		// check tag(3 bits) and valid/// 8Kb = 2048 word = 2^11 word
		// // addr = mem_addr = 0000000000000000|___|___________|__
		// //                  zero(memory size) tag    block     byte
		// if(hit):
			//if(byte_mode)
				// data_out = {sign_extend, cache_mem[addr%(1<<13)]
			//data_out = cache_mem[addr[31:2] + 0:3]
		// if(miss):
			// output_mem_addr = mem_addr
			// wait 4 clocks
			// cache[mem_add[12:2 + 0:3] = mem_data_out[0:3]
			// valid[mem_addr[12:2]] = 1
			// tag[mem_addr[12:2]] = mem_addr[15:13]
			// // output
			//if(byte_mode)
				// data_out = {sign_extend, cache_mem[addr%(1<<13)]
			//data_out = cache_mem[addr[31:2] + 0:3]
		
	reg [7:0] cache_mem [8191:0];
	reg clk_counter;
	reg valid [2048:0];
	reg dirty [2048:0];
	reg [2:0] tag[2048:0];

	reg [2:0] curr_tag;
	reg [10:0] curr_block;
	reg [1:0] curr_byte;

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
				clk_counter[i] =0;
				valid[i]=0;
				tag[i] =0;
				dirty[i] =0;
			end
		end else begin
			if(enable) begin
				if(write_enable) begin
					//TODO: write
				end else begin
					if( !( (curr_tagg == tag[curr_block]) && valid[curr_block] ) ) begin // miss -> fetch from memory
						ready = 0;
						output_mem_addr = mem_addr;
						mem_write_en = 0;
						@(posedge clk); // we do this because memory doesnt have a ready signal. if the memory had a ready signal we could just @(posedge mem_ready)
						@(posedge clk);
						@(posedge clk);
						@(posedge clk); // to make sure mem_write_en is recieved by memory

						@(posedge clk);
						@(posedge clk);
						@(posedge clk);
						@(posedge clk); // memory delay

						cache_mem[{curr_block, 2'b00}] = mem_data_out[0];
						cache_mem[{curr_block, 2'b01}] = mem_data_out[1];
						cache_mem[{curr_block, 2'b10}] = mem_data_out[2];
						cache_mem[{curr_block, 2'b11}] = mem_data_out[3];

						tag[curr_block] = curr_tag;
						valid[curr_block] = 1;


					end // write to output
					data_out[0] = cache_mem[{curr_block, 2'b00}];
					data_out[1] = cache_mem[{curr_block, 2'b01}];
					data_out[2] = cache_mem[{curr_block, 2'b10}];
					data_out[3] = cache_mem[{curr_block, 2'b11}];

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
					end
				end
			end
		end

	end
	endmodule
