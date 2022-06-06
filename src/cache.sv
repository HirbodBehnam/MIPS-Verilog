module Cache(
    input wire clk,
    input wire rst_b,
    input wire [31:0] mem_addr, // the adderss to read/write
    input wire [7:0] data_in [0:3], // the data which we want to write in cache
    input wire [7:0] mem_data_out [0:3], // connected to memory data ouput
    input wire byte_mode, // should we write/read byte?
    input wire write_enable, // should we write?
    input wire enable, // do we anything to do with cache and memory?
    output wire [7:0] data_out [0:3], // data read or the data which must be written to
    output wire [31:0] output_mem_addr, // must be here because our cache is write back! or we want to read other words for block
    output reg mem_write_en, // should we enable the memory write
    output reg ready // is data_out ready?
    );

    reg [2:0] ready_counter;

    always @(posedge clk or negedge rst_b) begin
        ready <= 0;
        mem_write_en <= 0;
        if (!rst_b) begin
            ready_counter <= 0;
        end else begin
            if (enable) begin
                if (ready_counter == 5) begin // 5 because read the comment below
                    ready_counter <= 0;
                    ready <= 1;
                    $display("ready");
                end else
                    ready_counter <= ready_counter + 1;
                // On ready counter = 1 we are sure that the write_enable signal is ready
                // If I change the number to 0, we will have invalid signal on write_enable
                if (ready_counter == 1)
                    mem_write_en <= write_enable;
            end
        end
    end
    
    // TODO: DEBUG/REMOVE
    assign data_out = write_enable ? data_in : mem_data_out;
    assign output_mem_addr = mem_addr;

endmodule