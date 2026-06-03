import sound_pkg::*;

module bclk_gen(
    input logic clk,
    input logic rst_n,

    input logic enable_in,
    output logic enable_out,

    output logic bclk
);

enum logic [1:0] {IDLE, ONE, ZERO} state, state_nxt;

logic [31:0] counter, counter_nxt;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
        counter <= '0;
        enable_out <= '0;
    end else begin
        state <= state_nxt;
        counter <= counter_nxt;
        enable_out <= enable_in;
    end
end

always_comb begin
    state_nxt = state;

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

assign bclk = (state == ONE);

endmodule