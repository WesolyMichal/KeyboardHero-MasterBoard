module key_buffer(
    input logic clk,
    input logic rst_n,

    input logic read_data,
    input logic [7:0] rx_data,

    output logic [7:0] key
);

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        key <= '0;
    end else begin
        if(read_data) key <= rx_data;
        else key <= '0;
    end
end

endmodule