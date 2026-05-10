import game_pkg::*;

module game_engine (
    input logic clk,
    input logic rst_n,
    input logic tick,
    input logic song_start,

    input logic [5:0] buttons,
    input logic strum,

    input note_t note,
    output logic [7:0] note_addr,
    
    output game_if game_data
);

logic [7:0] note_addr_nxt;
game_if game_data_nxt;

note_t note_nxt, current_note;

logic [32:0] timer, timer_nxt;

enum logic [1:0] {IDLE, WAIT, SUSTAIN} state, state_nxt;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
        timer <= '0;
        note_addr <= '0;
        game_data <= '0;
    end else begin
        timer <= timer_nxt;
        state <= state_nxt;
        note_addr <= note_addr_nxt;
        game_data <= game_data_nxt;
    end
end

assign note_nxt = note;

always_comb begin
    timer_nxt = timer;
    state_nxt = state;
    note_addr_nxt = note_addr;
    game_data_nxt = {buttons, game_data.status};

    case(state)
        IDLE: begin
            state_nxt = (song_start == '1) ? WAIT : IDLE;
            note_addr_nxt = '0;
            game_data_nxt = {6'b0, IDLE};
        end
        WAIT: begin
            if(tick) begin
                state_nxt = (timer == note.waiting - 1) ? SUSTAIN : WAIT;
                timer_nxt = (timer == note.waiting - 1) ? 0 : timer + 1;

                if(strum) begin
                    if((timer >= note.waiting - HIT_MARGIN) && (buttons === note.buttons)) game_data.status = HIT;
                    else game_data.status = MISS;
                end
            end
        end
        SUSTAIN: begin
            if(tick) begin
                state_nxt = (timer == note.duration - 1) ? WAIT : SUSTAIN;
            end
        end
    endcase
end

endmodule