import game_pkg::*;

module song_rom(
    input logic clk,
    input logic [1:0] song_select,

    input logic [7:0] note_addr,
    output note_t note
);

note_t songs [0:3][0:127];

initial begin
    $readmemh("../../rtl/songs/song_0.data", songs[0]);
    $readmemh("../../rtl/songs/song_1.data", songs[1]);
    $readmemh("../../rtl/songs/song_2.data", songs[2]);
    $readmemh("../../rtl/songs/song_3.data", songs[3]);
end

always_ff @(posedge clk)
    note <= songs[song_select][note_addr];

endmodule