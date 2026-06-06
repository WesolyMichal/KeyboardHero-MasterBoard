module sound_fsm(
    input logic clk,
    input logic rst_n,

    input logic song_start,
    input logic song_stop,
    input logic final_note,

    input logic [1:0] song_select_in,

    output logic enable,
    output logic song_select_out
);

enum logic {IDLE, PLAYING} state, state_nxt;
logic [1:0] song_select_nxt;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
        song_select_out <= '0;
    end else begin
        state <= state_nxt;
        song_select_out <= song_select_nxt;
    end
end

always_comb begin
    case(state)
        IDLE: state_nxt = (song_start) ? PLAYING : IDLE;
        PLAYING: state_nxt = (song_stop || final_note) ? IDLE : PLAYING;
    endcase
end

always_comb begin
    song_select_nxt = (state == IDLE) ? song_select_in : song_select_out;
    enable = (state == PLAYING);
end

endmodule