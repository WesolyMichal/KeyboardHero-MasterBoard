import game_pkg::*;

module top_master_tb;
    
    timeunit 1ns;
    timeprecision 1ps;

    localparam CLK40_PERIOD = 25;
    localparam CLK100_PERIOD = 10;

    /*
     * Input signal
     */
    logic clk40MHz, clk100MHz, rst_n;

    logic [7:0] Ps2Input;
    logic Ps2Send;

    wire ps2_clk, ps2_data;

    pullup(ps2_clk);
    pullup(ps2_data);

    /*
     * Output signals
     */

    wire uart_tx;
    wire logic [7:0] led;

    /*
     * Clocks
     */

    initial begin: clk40
        clk40MHz = 1'b1;
        forever #(CLK40_PERIOD/2) clk40MHz = ~clk40MHz;
    end

    initial begin: clk100
        clk100MHz = 1'b1;
        forever #(CLK100_PERIOD/2) clk100MHz = ~clk100MHz;
    end

    task reset;
        rst_n = 1'b0;
        {Ps2Input, Ps2Send} = '0;
        @(negedge clk100MHz) rst_n = 1'b1; 
    endtask

    task send_input(logic [7:0] data);
        Ps2Input = data;
        Ps2Send = 1'b1;
        repeat(5) @(negedge clk100MHz);
        Ps2Send = 1'b0;
    endtask

    initial begin: main
        reset();
        send_input(ENTER);

        $finish;
    end

    Ps2Interface u_Input_Ps2(
        .clk(clk100MHz),
        .rst(!rst_n),
        .ps2_clk,
        .ps2_data,
        
        .tx_data(Ps2Input),
        .write_data(Ps2Send)
    );

    top_master dut(
        .clk100MHz,
        .clk40MHz,

        .rst_n,

        .PS2_clk(ps2_clk),
        .PS2_data(ps2_data),

        .uart_tx,
        .led
    );

endmodule