import sound_pkg::*;

module record_player_tb;

    timeunit 1ns;
    timeprecision 1ps;

    localparam CLK_PERIOD = 25; 

    logic clk, rst_n;

    logic song_start, song_stop;
    logic [1:0] song_select;

    logic tick, fsm_enable, timer_enable;

    wire music_note music_note_rom;
    wire logic [7:0] note_addr;

    wire [1:0] fsm_song_select;
    wire final_note;

    wire note_enum notes [0:2];

    initial begin
        clk = 1'b1;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        rst_n = '0;
        song_start = '0;
        song_stop = '0;
        song_select = '0;
        @(negedge clk) rst_n = '1;
        repeat(10) @(negedge clk);
        song_select = '1;
        repeat(10) @(negedge clk);
        song_start = '1;
        @(negedge clk) song_start = '0;
        
        #5ms;
        @(negedge clk) song_stop = '1;
        @(negedge clk) song_stop = '0;

        #1ms;

        $finish;
    end

    sound_fsm u_sound_fsm(
        .clk,
        .rst_n,
        .enable(fsm_enable),
        .song_select_in(song_select),
        .song_select_out(fsm_song_select),
        .song_start(song_start),
        .song_stop,
        .final_note
    );

    record_rom u_record_rom(
        .clk,
        .music_note_out(music_note_rom),
        .note_addr,
        .song_select(fsm_song_select)
    );

    timer #(
        .FREQUENCY(400_000)
    ) u_song_timer (
        .clk,
        .rst_n,
        .tick,
        .enable(fsm_enable),
        .enable_out(timer_enable)
    );

    record_player u_record_player(
        .clk,
        .rst_n,
        .enable(timer_enable),
        .final_note,
        .music_note_in(music_note_rom),
        .note_addr,
        .notes,
        .tick_in(tick)
    );

endmodule