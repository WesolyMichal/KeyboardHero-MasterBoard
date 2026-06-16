import sound_pkg::*;

module bclk_gen(
    input logic clk,
    input logic rst_n,

    input logic enable_in,
    output pmod_internal pmod_out
);

enum logic [1:0] {IDLE, ONE, ZERO} state, state_nxt;

logic [31:0] counter, counter_nxt;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
        counter <= '0;
        pmod_out.enable <= '0;
        pmod_out.lrclk <= '0;
    end else begin
        state <= state_nxt;
        counter <= counter_nxt;
        pmod_out.enable <= enable_in;
    end
end

always_comb begin
    state_nxt = state;
    counter_nxt = counter;

    case(state)
        IDLE: begin
            if(enable_in) begin
                state_nxt = ONE;
                counter_nxt = BCLK_HALF_PERIOD - 1;
            end else counter_nxt = '0;
        end
        ZERO: begin
            if(enable_in) begin
                if(counter <= 0) begin
                    state_nxt = ONE;
                    counter_nxt = BCLK_HALF_PERIOD - 1;
                end else counter_nxt = counter - 1;
            end else state_nxt = IDLE;
        end
        ONE: begin
            if(enable_in) begin
                if(counter <= 0) begin
                    state_nxt = ZERO;
                    counter_nxt = BCLK_HALF_PERIOD - 1;
                end else counter_nxt = counter - 1;
            end else state_nxt = IDLE;
        end
    endcase
end

assign pmod_out.bclk = (state == ONE);

endmodule