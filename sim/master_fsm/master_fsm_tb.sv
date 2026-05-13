import game_pkg::*;

module master_fsm_tb;

    timeunit 1ns;
    timeprecision 1ps;

    localparam CLK_PERIOD = 25; 

    logic clk, rst_n;

    logic [7:0] key;
    game_if engine;
    logic UART_ready;

    wire logic timer_enable;
    wire logic [7:0] UART_data;
    wire logic UART_select;

    wire logic [3:0] song_select;
    wire logic song_start;
    wire logic song_stop;

    /*
        Clock generation
    */

    initial begin
        clk = 1'b1;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    master_fsm dut(
        .clk,
        .rst_n,

        .key,
        .engine,

        .UART_ready,
        .UART_data,
        .UART_select,

        .timer_enable,

        .song_select,
        .song_start,
        .song_stop
    );

    initial begin
        UART_ready = 1'b1;
        engine = '0;
        key = '0;
        rst_n = 1'b1;
        @(negedge clk) rst_n = 1'b0;
        @(negedge clk) rst_n = 1'b1;

        repeat(10) @(negedge clk);
        key = ENTER;
        @(negedge clk) key = '0;
        
        repeat(5) @(negedge clk);
        key = ARR_RIGHT;
        @(negedge clk) key = ARR_RIGHT;
        @(negedge clk) key = ARR_RIGHT;
        @(negedge clk) key = ARR_LEFT;
        @(negedge clk) key = '0;

        repeat(5) @(negedge clk);
        key = ENTER;
        @(negedge clk) key = '0;

        repeat(20) @(negedge clk);
        engine.status = END_GAME;
        @(negedge clk) engine.status = PLAYER_IDLE;

        repeat(5) @(negedge clk);
        key = ESC;
        @(negedge clk) key = '0;

        repeat(5) @(negedge clk);
        key = ARR_RIGHT;
        @(negedge clk) key = ARR_RIGHT;
        @(negedge clk) key = ARR_LEFT;
        @(negedge clk) key = '0;

        repeat(5) @(negedge clk);
        key = ENTER;

        repeat(10) @(negedge clk);
        key = ESC;
        @(negedge clk) key = '0;

        repeat(10) @(negedge clk);
        $finish;

    end

    
endmodule