module sound_gen_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import sound_pkg::*;

    localparam real CLK40_PERIOD = 25;

    localparam logic [3:0] NOTES = 3;

    logic enable, clk, rst_n, damped;

    note_enum notes [0:NOTES-1];
    wire note_enum notes_acc [0:NOTES-1];

    wire logic [23:0] phase_shift [0:NOTES-1];
    wire logic [7:0] phase [0:NOTES-1];
    
    wire logic [7:0] value_rom [0:NOTES-1], value_mix;

    wire pmod_internal pmod_bclk, pmod_lrclk, pmod_acc, pmod_mix;

    wire pmod_if pmod_amp3;

    initial begin: clk40
        clk = 1'b1;
        forever #(CLK40_PERIOD/2) clk = ~clk;
    end

    initial begin
        notes[0] = G5;
        notes[1] = E5;
        notes[2] = C5;
        #5ms;
        notes[0] = G5;
        notes[1] = E5;
        notes[2] = C6;
    end

    initial begin
        enable = '0;
        rst_n = '0;
        damped = '0;
        @(negedge clk) rst_n = '1;
        @(negedge clk) enable = '1;

        #10ms;

        $finish;
    end
    
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

    phase_inc_rom u_pitch_rom(
        .note_index(notes),
        .phase_shift
    );
    
    phase_acc_note u_phase_acc_note(
        .clk,
        .rst_n,
        .pmod_in(pmod_lrclk),
        .pmod_out(pmod_acc),
        .notes_in(notes),
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