module button_decoder_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import game_pkg::*;

    localparam SLOW_CLK_PERIOD = 25;
    localparam FAST_CLK_PERIOD = 10;

    logic clk40MHz, clk100MHz, rst_n;

    wire read_data_40MHz;

    logic read_data_100MHz;
    logic [7:0] rx_data;
    logic enable;

    wire [5:0] buttons;
    wire strum;

    wire navigation controls;

    wire tick;

    initial begin
        clk40MHz = 1'b0;
        forever #(SLOW_CLK_PERIOD/2) clk40MHz = ~clk40MHz;
    end

    initial begin
        clk100MHz = 1'b0;
        forever #(FAST_CLK_PERIOD/2) clk100MHz = ~clk100MHz;
    end

    initial begin
        enable = 1'b0;
        forever begin
            @(posedge clk40MHz) enable = '0;
            repeat(2) @(posedge clk40MHz);
            @(posedge clk40MHz) enable = '1;
        end
    end

    task send(logic [7:0] msg);
        @(posedge clk100MHz) rx_data = msg;
        @(posedge clk100MHz) read_data_100MHz = '1;
        @(posedge clk100MHz) read_data_100MHz = '0;
        repeat(6) @(posedge clk100MHz);
    endtask

    task send_release;
        @(posedge clk100MHz) rx_data = RELEASED;
        @(posedge clk100MHz) read_data_100MHz = '1;
        @(posedge clk100MHz) read_data_100MHz = '0;
        repeat(6) @(posedge clk100MHz);
    endtask

    task pressing;
        repeat(3) send(ESC);

        repeat(3) send(ENTER);

        repeat(3) send(ARR_LEFT);

        repeat(3) send(ARR_RIGHT);

        repeat(3) send(BUTTON_1);

        repeat(10) @(negedge clk40MHz);

        send(BUTTON_2);

        repeat(10) @(negedge clk40MHz);

        send(BUTTON_3);

        repeat(10) @(negedge clk40MHz);

        send(BUTTON_4);

        repeat(10) @(negedge clk40MHz);

        send(BUTTON_5);

        repeat(10) @(negedge clk40MHz);

        send(BUTTON_6);

        repeat(10) @(negedge clk40MHz);

        send(STRUM);

        repeat(10) @(negedge clk40MHz);
    endtask

    task releasing;
        send_release();
        send(ESC);

        send_release();
        send(ENTER);

        send_release();
        send(ARR_LEFT);

        send_release();
        send(ARR_RIGHT);

        send_release();
        send(BUTTON_1);

        repeat(10) @(negedge clk40MHz);

        send_release();
        send(BUTTON_2);

        repeat(10) @(negedge clk40MHz);

        send_release();
        send(BUTTON_3);

        repeat(10) @(negedge clk40MHz);

        send_release();
        send(BUTTON_4);

        repeat(10) @(negedge clk40MHz);

        send_release();
        send(BUTTON_5);

        repeat(10) @(negedge clk40MHz);

        send_release();
        send(BUTTON_6);

        repeat(10) @(negedge clk40MHz);

        send_release();
        send(STRUM);

        repeat(10) @(negedge clk40MHz);
    endtask

    button_decoder u_button_decoder(
        .clk(clk40MHz),
        .rst_n,

        .read_data(read_data_40MHz),
        .rx_data,
        .enable,

        .buttons,
        .strum,

        .controls,

        .tick
    );

    input_synch u_input_synch(
        .clk40MHz,
        .clk100MHz,
        .rst_n,

        .read_data_100MHz,
        .read_data_40MHz
    );

    initial begin
        rst_n = '1;

        @(negedge clk40MHz) rst_n = '0;
        rx_data = '0;
        read_data_100MHz = '0;
        repeat(5) @(negedge clk40MHz);

        rst_n = '1;

        pressing();

        releasing();

        pressing();

        $finish;
    end

endmodule