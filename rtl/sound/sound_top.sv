import sound_pkg::*;

module sound_top(
    input logic clk,
    input logic rst_n,

    input logic [1:0] song_select,
    input logic song_start,
    input logic song_stop,

    output pmod_if pmod_amp3
);

endmodule