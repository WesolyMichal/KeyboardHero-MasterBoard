import game_pkg::*;

module game_engine (
    input logic clk,
    input logic rst_n,
    input logic tick_in,
    input logic song_start,
    input logic song_stop,

    input logic [5:0] buttons,
    input logic strum,

    input note_t note,
    output logic [7:0] note_addr,
    
    output game_if game_data,
    output logic [7:0] note_led,

    output logic UART_send
);

logic [7:0] note_addr_nxt;
game_if game_data_nxt;
logic UART_send_nxt;

note_t coming_note, current_note, current_note_nxt;

logic note_hit, note_hit_nxt;

logic [32:0] timer, timer_nxt;

enum logic [1:0] {IDLE, WAIT, SUSTAIN} state, state_nxt;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
        timer <= '0;
        note_addr <= '0;
        game_data <= '0;
        current_note <= '0;
        note_hit <= '0;
        UART_send <= '0;
    end else begin
        timer <= timer_nxt;
        state <= state_nxt;
        note_addr <= note_addr_nxt;
        game_data <= game_data_nxt;
        current_note <= current_note_nxt;
        note_hit <= note_hit_nxt;
        UART_send <= UART_send_nxt;
    end
end

assign coming_note = note;

assign note_led = {current_note.buttons, current_note.data[1:0]};

always_comb begin
    timer_nxt = timer;
    note_addr_nxt = note_addr;
    game_data_nxt = {buttons, game_data.status};
    current_note_nxt = current_note;
    note_hit_nxt = note_hit;
    UART_send_nxt = '0;

    case(state)
        IDLE: begin
            note_addr_nxt = '0;
            game_data_nxt = {6'b0, PLAYER_IDLE};
            current_note_nxt = coming_note;
        end
        WAIT: begin
            if(tick_in) begin
                timer_nxt = (timer >= current_note.waiting - 1) ? 0 : timer + 1;

                if(timer >= current_note.waiting - 1) note_addr_nxt = note_addr + 1;

                if(strum) begin
                    if(note_hit) game_data_nxt.status = MISS;
                    else if((timer >= current_note.waiting - HIT_MARGIN) && (buttons === current_note.buttons)) begin
                        game_data_nxt.status = HIT;
                        note_hit_nxt = '1;
                    end else game_data_nxt.status = MISS;
                end

                UART_send_nxt = '1;
            end
        end
        SUSTAIN: begin
            if(tick_in) begin
                if(timer >= current_note.duration - 1) begin

                    if(current_note.data == 4'hf) game_data_nxt.status = END_GAME;
                    else if(!note_hit) game_data_nxt.status = MISS;
                    else game_data_nxt.status = PLAYER_IDLE;

                    timer_nxt = '0;
                    note_hit_nxt = '0;
                    current_note_nxt = coming_note;

                end else begin
                    
                    if(strum) begin
                        if(note_hit) game_data_nxt.status = MISS;
                        else if((timer <= HIT_MARGIN) && ((buttons == current_note.buttons))) begin
                            game_data_nxt.status = HIT;
                            note_hit_nxt = '1;
                        end else game_data_nxt.status = MISS;
                    end

                    if(game_data.status == HIT) begin
                        if (((buttons & current_note.long) == current_note.long) 
                        && (current_note.long != '0)) game_data_nxt.status = HIT;
                        else game_data_nxt.status = PLAYER_IDLE;
                    end

                    timer_nxt = timer + 1;
                end
                
                UART_send_nxt = '1;
                
            end
        end
    endcase
end

always_comb begin
    state_nxt = state;

    case(state)
        IDLE: state_nxt = (song_start == '1) ? WAIT : IDLE;

        WAIT: if(tick_in) state_nxt = (timer >= current_note.waiting - 1) ? SUSTAIN : WAIT;

        SUSTAIN: begin
            if(tick_in) begin
                if(timer >= current_note.duration - 1) state_nxt = (current_note.data == 4'hf) ? IDLE : WAIT;
                else state_nxt = SUSTAIN;
            end
        end
    endcase

    if(song_stop) state_nxt = IDLE;
end

endmodule