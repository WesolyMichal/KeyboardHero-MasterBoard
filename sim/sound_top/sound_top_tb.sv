module sound_top_tb;

    timeunit 1ns;
    timeprecision 1ps;

    localparam real CLK40_PERIOD = 25;

    logic clk, rst_n, song_start, song_stop, damped;

    logic [1:0] song_select;

    wire [4:0] pmod_amp3;

    initial begin: clk40
        clk = 1'b1;
        forever #(CLK40_PERIOD/2) clk = ~clk;
    end

    initial begin
        rst_n = '0;
        song_start = '0;
        song_stop = '0;
        damped = '0;
        song_select = '0;
        @(negedge clk) rst_n = '1;
        repeat(20) @(negedge clk);
        song_select = 2'd1;
        repeat(10) @(negedge clk);
        song_start = '1;
        @(negedge clk) song_start = '0;

        #11ms;

        $finish;
    end

    sound_top_4test #(
        .FREQUENCY(1_000_000)
    ) dut (
        .clk,
        .rst_n,
        .song_select,
        .song_start,
        .song_stop,
        .damped,
        .pmod_amp3
    );

endmodule