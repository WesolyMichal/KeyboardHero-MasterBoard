import sound_pkg::*;

module sound_top(
    input logic clk,
    input logic rst_n,

    input logic [1:0] song_select,
    input logic song_start,
    input logic song_stop,

    output pmod_if pmod_amp3
);

localparam logic [3:0] NOTES = 3;

wire enable;
wire pmod_internal pmod_bclk, pmod_lrclk, pmod_acc[0:0];

wire logic [7:0] phase [0:NOTES-1];

wire logic [15:0] wave_freq [0:NOTES-1];

wire logic [7:0] value [0:NOTES-1];

bclk_gen u_bclk_gen(
    .clk,
    .rst_n,
    .enable_in(enable),
    .pmod_out(pmod_bclk)
);

lrclk_gen u_lrclk_gen(
    .clk,
    .rst_n,
    .pmod_in(pmod_bclk),
    .pmod_out(pmod_lrclk)
);

phase_accumulator u_phase_accumulator(
    .clk,
    .rst_n,
    .pmod_in(pmod_lrclk),
    .pmod_out(pmod_acc),
    .phase,
    .wave_freq
);

sdata_gen u_sdata_gen(
    .clk,
    .rst_n,
    .pmod_in(pmod_acc),
    .l_data(value[0]),
    .r_data(value[1]),
    .pmod_out(pmod_amp3)
);

sine_rom u_sine_rom(
    .phase,
    .value
);

endmodule