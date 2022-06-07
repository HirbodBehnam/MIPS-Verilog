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

	reg [31:0] cache_mem [2047:0]; // cache blocks
	reg valid [2047:0]; // is the block valid
	reg dirty [2047:0]; // is block dirty or not?
	reg [2:0] tag [2047:0]; // tag of block

	// State of cache
	reg [1:0] state;
	localparam state_start = 2'b00, state_write_back = 2'b01, state_load = 2'b10, state_ready = 2'b11;
	reg [2:0] clk_counter;

	wire [2:0] curr_tag;
	wire [10:0] curr_block;
	wire [1:0] curr_byte;

	assign {curr_tag, curr_block, curr_byte} = mem_addr[15:0];

	always @(posedge clk or negedge reset) begin
		// always reset these outputs
		ready = 0;
		mem_write_en = 0;
		// check cache reset
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
			clk_counter = 0;
			state = state_start;
		end else begin
			if(enable) begin // if enable is not active we wont do anything
				case (state)
					state_start: begin // we should check for hit or miss and move on...
						if (curr_tag == tag[curr_block] && valid[curr_block]) begin // hit!
							if (write_enable) begin // we just write to cache
								dirty[curr_block] = 1; // we write so dirty!
								if (byte_mode) // check the index to write
									cache_mem[curr_block][curr_byte*8 +: 8] = data_in[3]; // https://stackoverflow.com/a/17779414
								else // just write to cache!
									cache_mem[curr_block] = {data_in[0], data_in[1], data_in[2], data_in[3]};
								$display("written %h on %h; block now %h", {data_in[0], data_in[1], data_in[2], data_in[3]}, curr_block, cache_mem[curr_block]);
							end else begin // we send out data
								{data_out[0], data_out[1], data_out[2], data_out[3]} = byte_mode
																				? {{24{cache_mem[curr_block][curr_byte*8+7]}}, cache_mem[curr_block][curr_byte*8 +: 8]}
																				: cache_mem[curr_block];
								$display("hit %h for %h", {data_out[0], data_out[1], data_out[2], data_out[3]}, mem_addr);
							end
							state = state_ready; // next we are ready...
						end else begin // miss :(
							valid[curr_block] = 1; // we will have something valid here
							if (dirty[curr_block]) begin // we have to write back
								mem_write_en = 1; // only for one clock!
								output_mem_addr = {16'b0, tag[curr_block], curr_block, 2'b0};
								clk_counter = 0;
								state = state_write_back; // write back
							end else begin
								output_mem_addr = {16'b0, curr_tag, curr_block, 2'b0}; // load the word
								clk_counter = 0;
								state = state_load; // go to load
							end
						end
					end
					state_write_back: begin
						if (clk_counter == 4) begin
							output_mem_addr = {16'b0, curr_tag, curr_block, 2'b0}; // load the word
							clk_counter = 0;
							state = state_load;
						end else
							clk_counter++;
					end
					state_load: begin
						if (clk_counter == 4) begin
							cache_mem[curr_block] = {mem_data_out[0], mem_data_out[1], mem_data_out[2], mem_data_out[3]};
							state = state_start;
							$display("cache set %h on %h as result", cache_mem[curr_block], curr_block);
						end else
							clk_counter++;
						//$display("waiting for load %h (%h | %h)", {mem_data_out[0], mem_data_out[1], mem_data_out[2], mem_data_out[3]}, mem_addr, output_mem_addr);
					end
					state_ready: begin
						ready = 1;
						state = state_start;
					end
				endcase
			end
		end
	end
endmodule
