module Cache(
    input wire clk,
    input wire reset,
    input wire [31:0] mem_addr,
    input wire [7:0] data_in [0:3],
    input wire byte_mode,
    input wire write_enable,
    input wire enable,
    output wire [7:0] data_out [0:3], // data read or the data which must be written to
    output wire [31:0] output_mem_addr, // must be here because our cache is write back!
    output wire mem_write_en, // should we enable the memory write
    output wire ready // is data_out ready?
    );
    
    // TODO: DEBUG/REMOVE
    assign ready = 1;
    assign data_out = data_in;
    assign output_mem_addr = mem_addr;
    assign mem_write_en = write_enable;

endmodule