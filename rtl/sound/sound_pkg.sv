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

    typedef enum logic [5:0] {
        SILENCE,
        C2, Csh2, D2, Dsh2, E2, F2, Fsh2, G2, Gsh2, A2, Ash2, B2,
        C3, Csh3, D3, Dsh3, E3, F3, Fsh3, G3, Gsh3, A3, Ash3, B3,
        C4, Csh4, D4, Dsh4, E4, F4, Fsh4, G4, Gsh4, A4, Ash4, B4,
        C5, Csh5, D5, Dsh5, E5, F5, Fsh5, G5, Gsh5, A5, Ash5, B5,
        C6
    } note_enum;

    typedef struct packed {
        logic [15:0] duration;
        note_enum note_pitch_0;
        note_enum note_pitch_1;
        note_enum note_pitch_2;
        logic [1:0] data;
    } music_note;

    localparam music_note NULL_MUSIC_NOTE = {16'b0, SILENCE, SILENCE, SILENCE, 2'b0};

endpackage
