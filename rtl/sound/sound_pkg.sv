package sound_pkg;

    typedef struct packed {
        logic lrclk;
        logic sdata;
        logic bclk;
        logic mclk_e;
        logic shutdown_n;
    } pmod_if;

    typedef struct packed {
        logic lrclk;
        logic bclk;
        logic enable;
    } pmod_internal;

    localparam LR_FREQ = 88_200;
    localparam CLK_FREQ = 40_000_000;

    localparam RESOLUTION_BITS = 8;

    localparam BCLK_HALF_PERIOD = 28;

endpackage
