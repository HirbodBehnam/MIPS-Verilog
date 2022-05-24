module ByteLoader (
    input wire [7:0] mem_data_in[0:3],
    input wire [31:0] mem_addr,
    output wire [7:0] mem_data_out
);
    assign mem_data_out = mem_data_in[mem_addr % 4];
endmodule