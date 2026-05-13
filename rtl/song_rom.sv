import game_pkg::*;

module song_rom(
    input logic clk,
    input logic [3:0] song_select,

    input logic [7:0] note_addr,
    output note_t note
);

note_t [127:0] songs [3:0];

initial begin
    $readmemh("../../rtl/songs/hejnal.data", songs[0]);
    $readmemh("../../rtl/songs/literka_AGH.data", songs[1]);
    $readmemh("../../rtl/songs/Stairway_To_Heaven.data", songs[2]);
    $readmemh("../../rtl/songs/wlaz_kotek.data", songs[3]);
end

always_ff @(posedge clk)
    note <= songs[song_select][note_addr];


endmodule