import game_pkg::*;

module master_fsm_tb;

    timeunit 1ns;
    timeprecision 1ps;

    localparam CLK_PERIOD = 25; 

    logic clk, rst_n;

    navigation controls;

    game_if engine;
    wire UART_send;

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

        .controls,

        .engine,

        .UART_data,
        .UART_select,
        .UART_send,

        .timer_enable,

        .song_select,
        .song_start,
        .song_stop
    );

    initial begin
        engine = '0;
        controls = '0;
        rst_n = 1'b1;
        @(negedge clk) rst_n = 1'b0;
        @(negedge clk) rst_n = 1'b1;

        repeat(10) @(negedge clk);
        controls.enter = '1;
        @(negedge clk) controls.enter = '0;
        
        repeat(5) @(negedge clk);
        controls.arr_right = '1;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk) controls.arr_right = '0;
        controls.arr_left = '1;
        @(negedge clk) controls.arr_left = '0;

        repeat(5) @(negedge clk);
        controls.enter = '1;
        @(negedge clk) controls.enter = '0;

        repeat(20) @(negedge clk);
        engine.status = END_GAME;
        @(negedge clk) engine.status = PLAYER_IDLE;

        repeat(5) @(negedge clk);
        controls.esc = '1;
        @(negedge clk) controls.esc = '0;

        repeat(5) @(negedge clk);
        controls.arr_right = '1;
        @(negedge clk);
        @(negedge clk) controls.arr_right = '0;
        controls.arr_left = '1;
        @(negedge clk) controls.arr_left = '0;

        repeat(5) @(negedge clk);
        controls.enter = '1;
        @(negedge clk) controls.enter = '0;

        repeat(9) @(negedge clk);
        controls.esc = '1;
        @(negedge clk) controls.esc = '0;

        repeat(10) @(negedge clk);
        $finish;

    end

    
endmodule