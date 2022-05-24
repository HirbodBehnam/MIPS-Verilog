module ByteSaver (
    input wire [7:0] mem_data_in[0:3],
    input wire [31:0] mem_addr,
    input wire [7:0] data,
    output reg [7:0] mem_data_out[0:3]
);
    always @(mem_data_in, mem_addr, data) begin
        mem_data_out = mem_data_in;
        mem_data_out[mem_addr % 4] = data;
    end
endmodule