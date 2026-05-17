module game_engine_tb;
    
    timeunit 1ns;
    timeprecision 1ps;

    localparam CLK_PERIOD = 25; 

    logic clk, rst_n;

    logic tick;
    logic song_start;

    logic [5:0] buttons;
    logic strum;

    note_t note;
    wire [7:0] note_addr;

    wire game_if game_data;

    initial begin
        clk = 1'b1;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        tick = 1'b0;
        forever begin
            repeat(9) @(negedge clk);
            tick = 1'b1;
            @(negedge clk) tick = 1'b0;
        end
    end

    game_engine dut(
        .clk,
        .rst_n,

        .tick,
        .song_start,

        .buttons,
        .strum,

        .note,
        .note_addr,

        .game_data
    );

endmodule