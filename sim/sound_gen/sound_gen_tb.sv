module sound_gen_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import sound_pkg::*;

    localparam real CLK40_PERIOD = 25;

    localparam logic [3:0] NOTES = 3;

    logic enable, clk, rst_n;

    logic [15:0] wave_freq [0:NOTES-1];

    wire logic [7:0] phase [0:NOTES-1];
    
    wire logic [7:0] value [0:NOTES-1];

    wire pmod_internal pmod_bclk, pmod_lrclk, pmod_acc;

    wire pmod_if pmod_amp3;

    initial begin: clk40
        clk = 1'b1;
        forever #(CLK40_PERIOD/2) clk = ~clk;
    end

    initial begin
        wave_freq[0] = 16'd1;
        wave_freq[1] = 16'd2_000;
        wave_freq[2] = 16'd3_000;
        forever @(negedge pmod_lrclk.lrclk) wave_freq[0] *= 2;
    end

    initial begin
        enable = '0;
        rst_n = '0;
        @(negedge clk) rst_n = '1;
        @(negedge clk) enable = '1;

        #2ms;

        $finish;
    end
    
    bclk_gen u_bclk_gen(
        .clk,
        .rst_n,
        .enable_in(enable),
        .pmod_out(pmod_bclk)
    );
    
    lrclk_gen u_lrclk_gen(
        .clk,
        .rst_n,
        .pmod_in(pmod_bclk),
        .pmod_out(pmod_lrclk)
    );
    
    phase_accumulator u_phase_accumulator(
        .clk,
        .rst_n,
        .pmod_in(pmod_lrclk),
        .pmod_out(pmod_acc),
        .phase,
        .wave_freq
    );
    
    sdata_gen u_sdata_gen(
        .clk,
        .rst_n,
        .pmod_in(pmod_acc),
        .l_data(value[0]),
        .r_data(value[1]),
        .pmod_out(pmod_amp3)
    );
    
    sine_rom u_sine_rom(
        .phase,
        .value
    );

endmodule