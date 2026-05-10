module timer #(
    parameter FREQUENCY = 1000
)(
    input logic clk,
    input logic rst_n,
    input logic enable,

    output logic [31:0] count,
    output logic overflow
);

localparam CLK_FREQUENCY = 40_000_000;

logic [31:0] count_nxt;
logic overflow_nxt;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        count       <= '0;
        overflow    <= '0;
    end else begin
        count <= count_nxt;
        overflow <= overflow_nxt;
    end
end

always_comb begin
    if(enable) begin
        if(count == '0) begin
            overflow_nxt = '1;
            count_nxt = CLK_FREQUENCY/FREQUENCY;
        end else begin
            overflow_nxt = '0;
            count_nxt = count - 1;
        end
    end else begin
        overflow_nxt = '0;
        count_nxt = CLK_FREQUENCY/FREQUENCY;
    end
end

endmodule