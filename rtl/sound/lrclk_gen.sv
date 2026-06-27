import sound_pkg::*;

module lrclk_gen(
    input logic clk,
    input logic rst_n,

    input pmod_internal pmod_in,
    output pmod_internal pmod_out
);

enum logic [1:0] {IDLE, LEFT, RIGHT} state, state_nxt;

logic [31:0] counter, counter_nxt;
logic bclk_last, bclk_last_nxt;

always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
        counter <= '0;
        bclk_last <= '0;
        pmod_out.bclk <= '0;
        pmod_out.enable <= '0;
    end else begin
        state <= state_nxt;
        counter <= counter_nxt;
        bclk_last <= bclk_last_nxt;
        pmod_out.bclk <= pmod_in.bclk;
        pmod_out.enable <= pmod_in.enable;
    end
end

always_comb begin
    state_nxt = state;
    counter_nxt = counter;

    case(state)
        IDLE: begin
            if(pmod_in.enable) begin
                state_nxt = LEFT;
                counter_nxt = LR_RESOLUTION_BITS - 1;
            end else counter_nxt = '0;
        end
        LEFT: begin
            if(pmod_in.enable) begin
                if((pmod_in.bclk) && (bclk_last == 0'b0)) begin
                    if(counter == '0) begin
                        state_nxt = RIGHT;
                        counter_nxt = LR_RESOLUTION_BITS - 1;
                    end else counter_nxt = counter - 1; 
                end else counter_nxt = counter;
            end else state_nxt = IDLE;
        end
        RIGHT: begin
            if(pmod_in.enable) begin
                if((pmod_in.bclk) && (bclk_last == 0'b0)) begin
                    if(counter == 32'b0) begin
                        state_nxt = LEFT;
                        counter_nxt = LR_RESOLUTION_BITS - 1;
                    end else counter_nxt = counter - 1; 
                end else counter_nxt = counter;
            end else state_nxt = IDLE;
        end
    endcase

    bclk_last_nxt = pmod_in.bclk;
end

assign pmod_out.lrclk = (state == RIGHT) || (state == IDLE);

endmodule