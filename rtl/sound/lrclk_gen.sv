import sound_pkg::*;

module lrclk_gen(
    input logic clk,
    input logic rst_n,

    input logic enable_in,
    output logic enable_out,

    input logic bclk_in,

    output logic lrclk,
    output logic bclk_out
);

enum logic [1:0] {IDLE, LEFT, RIGHT} state, state_nxt;

logic [31:0] counter, counter_nxt;
logic bclk_last, bclk_last_nxt;

always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
        counter <= '0;
        bclk_last <= '0;
        bclk_out <= '0;
        enable_out <= '0;
    end else begin
        state <= state_nxt;
        counter <= counter_nxt;
        bclk_last <= bclk_last_nxt;
        bclk_out <= bclk_in;
        enable_out <= enable_in;
    end
end

always_comb begin
    state_nxt = state;

    case(state)
        IDLE: begin
            if(enable_in) begin
                state_nxt = LEFT;
                counter_nxt = RESOLUTION_BITS - 1;
            end else counter_nxt = '0;
        end
        LEFT: begin
            if(enable_in) begin
                if((bclk_in) && (bclk_last == 0'b0)) begin
                    if(counter == 0) begin
                        state_nxt = RIGHT;
                        counter_nxt = RESOLUTION_BITS - 1;
                    end else counter_nxt = counter - 1; 
                end else counter_nxt = counter;
            end else state_nxt = IDLE;
        end
        RIGHT: begin
            if(enable_in) begin
                if((bclk_in) && (bclk_last == 0'b0)) begin
                    if(counter == 0) begin
                        state_nxt = LEFT;
                        counter_nxt = RESOLUTION_BITS - 1;
                    end else counter_nxt = counter - 1; 
                end else counter_nxt = counter;
            end else state_nxt = IDLE;
        end
    endcase

    bclk_last_nxt = bclk_in;
end

assign lrclk = (state == RIGHT) || (state == IDLE);

endmodule