module sound_gen_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import sound_pkg::*;

    localparam real CLK40_PERIOD = 25;

    logic clk40MHz, rst_n, enable;

    logic [7:0] sample_number [0:2];

    wire enable_bclk, enable_lrclk;

    wire bclk_orig, bclk_lr;
    wire lrclk_orig;

    wire pmod_if pmod_out;
    wire [7:0] data [0:2];

    initial begin: clk40
        clk40MHz = 1'b1;
        forever #(CLK40_PERIOD/2) clk40MHz = ~clk40MHz;
    end

    initial begin
        sample_number[0] = '0;
        sample_number[1] = '0;
        sample_number[2] = '0;
        forever @(negedge pmod_out.lrclk) begin
            sample_number[0] += 3;
            sample_number[1] += 6;
            sample_number[2] += 9;
        end
    end

    initial begin
        rst_n = '0;
        @(negedge clk40MHz) rst_n = '1;
        @(negedge clk40MHz) enable = '1;

        #2ms;

        $finish;
    end

    bclk_gen u_bclk_gen(
        .clk(clk40MHz),
        .rst_n,
        .enable_in(enable),
        .enable_out(enable_bclk),
        .bclk(bclk_orig)
    );

    lrclk_gen u_lrclk_gen(
        .clk(clk40MHz),
        .rst_n,
        .bclk_in(bclk_orig),
        .bclk_out(bclk_lr),
        .enable_in(enable_bclk),
        .enable_out(enable_lrclk),
        .lrclk(lrclk_orig)
    );

    sdata_gen u_sdata_gen(
        .clk(clk40MHz),
        .rst_n,
        .bclk_in(bclk_lr),
        .lrclk_in(lrclk_orig),
        .enable(enable_lrclk),
        .l_data(data[0]),
        .r_data(data[1]),
        .pmod_out
    );
    
    sine_rom u_sine_rom(
        .sample_number,
        .value(data)
    );

endmodule