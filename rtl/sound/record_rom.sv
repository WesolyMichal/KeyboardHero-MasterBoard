import sound_pkg::*;

module record_rom(
    input logic clk,
    input logic [1:0] song_select,
    
    input logic [7:0] note_addr,
    output music_note music_note_out
);

logic [35:0] track_0 [0:255];
logic [35:0] track_1 [0:255];
logic [35:0] track_2 [0:255];
logic [35:0] track_3 [0:255];

initial begin
    $readmemh("../../rtl/sound/music/track_0.data", track_0);
    $readmemh("../../rtl/sound/music/track_1.data", track_1);
    $readmemh("../../rtl/sound/music/track_2.data", track_2);
    $readmemh("../../rtl/sound/music/track_3.data", track_3);
end

always_ff @(posedge clk) begin
    case(song_select)
        2'd0: music_note_out <= track_0[note_addr];
        2'd1: music_note_out <= track_1[note_addr];
        2'd2: music_note_out <= track_2[note_addr];
        2'd3: music_note_out <= track_3[note_addr];
    endcase
end

endmodule