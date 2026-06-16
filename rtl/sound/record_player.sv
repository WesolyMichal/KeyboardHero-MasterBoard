import sound_pkg::*;

module record_player(
    input logic clk,
    input logic rst_n,

    input logic tick_in,
    input logic enable,

    input music_note music_note_in,

    output note_enum notes [0:2],
    output logic [7:0] note_addr,
    output logic final_note
);

logic enable_last;

enum logic {IDLE, PLAYING} state, state_nxt;

note_enum notes_nxt[0:2];
logic final_note_nxt;
logic [7:0] note_addr_nxt;

music_note coming_note, current_note, current_note_nxt;

logic [15:0] counter, counter_nxt;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        {notes[0], notes[1], notes[2]} <= '0;
        final_note <= '0;
        note_addr <= '0;
        counter <= '0;
        state <= IDLE;
        enable_last <= '0;
        coming_note <= NULL_MUSIC_NOTE;
        current_note <= NULL_MUSIC_NOTE;
    end else begin
        notes <= notes_nxt;
        final_note <= final_note_nxt;
        note_addr <= note_addr_nxt;
        counter <= counter_nxt;
        state <= state_nxt;
        enable_last <= enable;
        coming_note <= music_note_in;
        current_note <= (state == PLAYING) ? current_note_nxt : music_note_in;
    end
end

always_comb begin: state_blk
    case(state)
        IDLE: state_nxt = (enable && (enable_last == '0)) ? PLAYING : IDLE;
        PLAYING: state_nxt = (final_note || (!enable)) ? IDLE : PLAYING;
    endcase
end: state_blk

always_comb begin: final_note_blk
    case(state)
        IDLE: final_note_nxt = '0;
        PLAYING: begin
            if((counter == '0) && (current_note.data == 2'b11)) final_note_nxt = '1;
            else final_note_nxt = '0;
        end
    endcase
end: final_note_blk

always_comb begin: counter_blk
    counter_nxt = counter;

    case(state)
        IDLE: counter_nxt = (enable) ? current_note.duration : '0;
        PLAYING: begin
            if(tick_in) begin
                if(counter <= 0) counter_nxt = coming_note.duration - 1;
                else counter_nxt = counter - 1;
            end
        end
    endcase

end: counter_blk

always_comb begin: notes_out_blk
    notes_nxt = notes;

    case(state)
        IDLE: {notes_nxt[0], notes_nxt[1], notes_nxt[2]} = '0;
        PLAYING: begin
            if(counter <= 0) notes_nxt = {coming_note.note_pitch_0, coming_note.note_pitch_1, coming_note.note_pitch_2};
            else notes_nxt = {current_note.note_pitch_0, current_note.note_pitch_1, current_note.note_pitch_2};
        end
    endcase

end: notes_out_blk

always_comb begin: note_addr_blk
    note_addr_nxt = note_addr;

    case(state)
        IDLE: note_addr_nxt = '0;
        PLAYING: if(tick_in && (counter == 1)) note_addr_nxt = note_addr + 1;
    endcase

end: note_addr_blk

always_comb begin: music_notes_blk
    current_note_nxt = current_note;

    case(state)
        IDLE: current_note_nxt = current_note;
        PLAYING: begin
            if(counter <= 0) current_note_nxt = coming_note;
        end
    endcase
end: music_notes_blk

endmodule