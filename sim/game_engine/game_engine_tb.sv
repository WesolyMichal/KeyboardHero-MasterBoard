import game_pkg::*;

module game_engine_tb;
    
    timeunit 1ns;
    timeprecision 1ps;

    localparam CLK_PERIOD = 25; 

    /*
     * Input signal
     */
    logic clk, rst_n;

    logic tick;
    logic song_start, song_stop;

    logic [5:0] buttons;
    logic strum;

    note_t note;

    /*
     * Output signals
     */
    wire [7:0] note_addr;

    wire logic UART_send;

    wire game_if game_data;

    /*
     * Hit enum
     */

    typedef enum logic [2:0] {EARLY, LITTLE_EARLY, ON, LITTLE_LATE, LATE} hit_time;
    typedef enum logic [1:0] {WRONG, CORRECT, HOLD_FULL, HOLD_PART} hit_type;

    initial begin: clk_blk
        clk = 1'b1;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin: tick_blk
        tick = 1'b0;
        forever begin
            repeat(9) @(negedge clk);
            tick = 1'b1;
            @(negedge clk) tick = 1'b0;
        end
    end

    task reset;
        {song_start, song_stop, note} = '0;
        rst_n = '1;
        repeat(5) @(negedge clk);
        rst_n = '0;
        @(negedge clk) rst_n = '1;
    endtask

    task set_note(logic [15:0] waiting, duration, logic [5:0] buttons, long, logic [3:0] data);
        note.waiting = waiting;
        note.duration = duration;
        note.buttons = buttons;
        note.long = long;
        note.data = data;
    endtask

    task begin_song;
        set_note(10, 10, 6'b110011, 6'b000011, 4'h0);
        @(negedge clk) song_start = '1;
        @(negedge clk) song_start = '0;
    endtask

    task end_song;
        repeat(note.duration + note.waiting) @(negedge tick);
        note.data = 4'hf;
        repeat(note.duration + note.waiting) @(negedge tick);
    endtask

    task interruption;
        repeat(3 * (note.duration + note.waiting)) @(negedge tick);
        song_stop = '1;
        @(negedge clk) song_stop = '0;
        repeat(20) @(negedge clk);
    endtask

    task hit(hit_time timing, hit_type accuracy);
        @(negedge clk) strum = '0;
        case(accuracy)
            WRONG: buttons = note.buttons ^ 8'hff;
            default: buttons = note.buttons;
        endcase
        @(posedge note_addr);
        repeat(note.duration) @(negedge tick);
        case(timing)
            EARLY: repeat(note.waiting - (HIT_MARGIN + 2)) @(negedge tick);
            LITTLE_EARLY: repeat(note.waiting - 2) @(negedge tick);
            ON: repeat(note.waiting) @(negedge tick);
            LITTLE_LATE: repeat(note.waiting + 2) @(negedge tick);
            LATE: repeat(note.waiting + (HIT_MARGIN + 2)) @(negedge tick);
        endcase
        @(negedge tick) strum = '1;
        @(negedge tick) strum = '0;
        case(accuracy)
            HOLD_FULL: repeat(note.duration - 1) @(negedge tick);
            HOLD_PART: repeat(note.duration/2 - 1) @(negedge tick);
            default: @(negedge tick);
        endcase
        buttons = '0;
        strum = '0;
    endtask

    initial begin: main
        reset();

        begin_song();
        hit(ON, HOLD_FULL);
        end_song();

        $finish;
    end

    game_engine dut(
        .clk,
        .rst_n,

        .tick,
        .song_start,
        .song_stop,

        .buttons,
        .strum,

        .note,
        .note_addr,

        .game_data,
        .UART_send
    );

endmodule