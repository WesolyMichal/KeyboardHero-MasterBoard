import sound_pkg::*;

module sound_top(
    input logic clk,
    input logic rst_n,

    input logic [1:0] song_select,
    input logic song_start,
    input logic song_stop,

    input logic damped,

    output pmod_if pmod_amp3
);

localparam logic [3:0] NOTES = 3;

wire logic fsm_enable, timer_enable, final_note, tick_orig;

wire note_enum notes_acc  [0:NOTES-1];
wire note_enum notes_orig [0:NOTES-1];

wire logic [23:0] phase_shift [0:NOTES-1];
wire logic [7:0]  phase       [0:NOTES-1];
wire logic [7:0]  value_rom   [0:NOTES-1];

wire logic [7:0]  value_mix;

wire pmod_internal pmod_bclk, pmod_lrclk, pmod_acc, pmod_mix;

sound_fsm u_sound_fsm(
    .clk,
    .rst_n,
    .song_start,
    .song_stop,
    .enable(fsm_enable),
    .final_note,
    .song_select_in(song_select)
);

timer u_sound_timer(
    .clk,
    .rst_n,
    .enable(fsm_enable),
    .enable_out(timer_enable),
    .tick(tick_orig)
);

record_player u_record_player(
    .clk,
    .rst_n,
    .enable(timer_enable),
    .tick_in(tick_orig),
    .final_note,
    .notes(notes_orig)
);

bclk_gen u_bclk_gen(
    .clk,
    .rst_n,
    .enable_in(fsm_enable),
    .pmod_out(pmod_bclk)
);

lrclk_gen u_lrclk_gen(
    .clk,
    .rst_n,
    .pmod_in(pmod_bclk),
    .pmod_out(pmod_lrclk)
);

phase_inc_rom u_pitch_rom(
    .note_index(notes_orig),
    .phase_shift
);

phase_acc_note u_phase_acc_note(
    .clk,
    .rst_n,
    .pmod_in(pmod_lrclk),
    .pmod_out(pmod_acc),
    .notes_in(notes_orig),
    .notes_out(notes_acc),
    .phase_shift,
    .phase
);

sine_rom u_sine_rom(
    .phase,
    .value(value_rom)
);

mixer u_mixer(
    .clk,
    .rst_n,
    .pmod_in(pmod_acc),
    .pmod_out(pmod_mix),
    .value_in(value_rom),
    .value_out(value_mix),
    .notes_in(notes_acc),
    .damped
);

sdata_gen u_sdata_gen(
    .clk,
    .rst_n,
    .pmod_in(pmod_mix),
    .l_data(value_mix),
    .r_data(value_mix),
    .pmod_out(pmod_amp3)
);

endmodule