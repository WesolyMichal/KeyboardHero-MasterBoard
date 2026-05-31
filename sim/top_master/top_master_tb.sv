import game_pkg::*;

module top_master_tb;
    
    timeunit 1ns;
    timeprecision 1ps;

    localparam CLK40_PERIOD = 25;

    /*
     * Input signal
     */
    logic clk40MHz, rst_n;

    logic [7:0] rx_data;
    logic read_data;

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

    task reset;
        rst_n = 1'b0;
        {rx_data, read_data} = '0;
        @(negedge clk40MHz) rst_n = 1'b1;
    endtask

    task send_input(logic [7:0] data);
        @(negedge clk40MHz);
        rx_data = data;
        read_data = 1'b1;
        @(negedge clk40MHz);
        {rx_data, read_data} = '0;
    endtask

    task send_and_release(logic [7:0] data);
        #1ms;
        send_input(data);
        send_input(RELEASED);
        send_input(data);
    endtask

    initial begin: main
        reset();

        send_and_release(ENTER);

        send_and_release(ARR_RIGHT);

        send_and_release(ARR_RIGHT);

        send_and_release(ARR_LEFT);

        send_and_release(ENTER);

        #1ms;
        send_input(BUTTON_1);
        #1ms;
        send_input(BUTTON_2);
        #1ms;
        send_input(BUTTON_3);
        #1ms;
        send_input(BUTTON_4);
        #1ms;
        send_input(BUTTON_5);
        #1ms;
        send_input(BUTTON_6);
        #1ms;
        send_input(STRUM);
        
        #2ms;
        send_and_release(ESC);

        #1ms;
        $finish;
    end

    top_master_4test dut(
        .clk40MHz,

        .rst_n,

        .rx_data,
        .read_data,

        .uart_tx,
        .led
    );

endmodule