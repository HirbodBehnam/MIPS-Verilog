module BinaryToFloat (
    input wire [31:0] in,
    output reg [31:0] out,
    output reg inexact
);

    wire negative_input = in[31];
    wire [63:0] in_abs = {negative_input ? -in : in, 32'b0};
    reg [5:0] counter, msb_index;
    reg [7:0] exponent;

    always_comb begin
        // Reset signals
        {inexact, counter, msb_index, exponent} = 0;
        // Check special cases
        if (in_abs == 0) begin
            out = 0;
        end else begin
            // Find the index of first 1
            for (counter = 63; counter > 31; counter--) begin
                if (in_abs[counter] & msb_index == 0)
                    msb_index = counter;
            end
            // Set the exponent
            exponent = {2'b0, msb_index};
            exponent += 127 - 32; // 32 to align
            // Now set the out
            out = {negative_input, exponent, in_abs[(msb_index - 1) -: 23]};
            // Check inexact
            for (counter = msb_index - 24; counter > 31; counter--) begin
                if (in_abs[counter])
                    inexact = 1; 
            end
        end
    end
    
endmodule