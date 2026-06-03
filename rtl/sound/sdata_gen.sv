import sound_pkg::*;

module sdata_gen(
    input logic clk,
    input logic rst_n,

    input logic [RESOLUTION_BITS-1:0] r_data,
    input logic [RESOLUTION_BITS-1:0] l_data,

    input logic lrclk_in,
    input logic bclk_in,

    input logic enable,

    output pmod_if pmod_out
);

pmod_if pmod_out_nxt;

logic lrclk_edge, bclk_posedge;

logic [5:0] bit_counter, bit_counter_nxt;

logic [RESOLUTION_BITS-1:0] current_data, current_data_nxt;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pmod_out <= '0;
        bit_counter <= '0;
        current_data <= '0;
    end else begin
        pmod_out <= pmod_out_nxt;
        bit_counter <= bit_counter_nxt;
        current_data <= current_data_nxt;
    end
end

always_comb begin
    pmod_out_nxt.bclk = bclk_in;
    pmod_out_nxt.lrclk = lrclk_in;
    pmod_out_nxt.mclk_e = clk;

    pmod_out_nxt.sdata = pmod_out.sdata;
    current_data_nxt = current_data;
    bit_counter_nxt = bit_counter;

    lrclk_edge = (lrclk_in != pmod_out.lrclk);
    bclk_posedge = (pmod_out.bclk == 1'b0) && (bclk_in == 1'b1);

    if(enable) begin
        if(bclk_posedge) begin
            if(lrclk_edge) begin
                case(lrclk_in)
                    1'b0: begin
                        current_data_nxt = l_data;
                        pmod_out_nxt.sdata = l_data[RESOLUTION_BITS - 1];
                        bit_counter_nxt = RESOLUTION_BITS - 1;
                    end
                    1'b1: begin
                        current_data_nxt = r_data;
                        pmod_out_nxt.sdata = r_data[RESOLUTION_BITS - 1];
                        bit_counter_nxt = RESOLUTION_BITS - 1;
                    end
                endcase
            end else begin
                bit_counter_nxt = bit_counter - 1;
                pmod_out_nxt.sdata = current_data[bit_counter - 1];
            end
        end
    end else begin
        current_data_nxt = '0;
        pmod_out_nxt.sdata = '0;
        bit_counter_nxt = '0;
    end
end

assign pmod_out_nxt.shutdown_n = ~enable;

endmodule