package game_pkg;

    typedef struct packed {
        logic [15:0] duration;
        logic [15:0] waiting;
        logic [5:0] buttons;
        logic [5:0] long;
        logic [3:0] data;
    } note_t;

    typedef enum logic [1:0] {HIT, MISS, STOP, END_GAME} game_action;

    typedef struct packed {
        logic [5:0] buttons;
        game_action status;
    } game_status;

    localparam logic [11:0] COLOUR_RED = 12'hf_0_0;
    localparam logic [11:0] COLOUR_GREEN = 12'h0_f_0;
    localparam logic [11:0] COLOUR_BLUE = 12'h0_0_f;
    localparam logic [11:0] COLOUR_YELLOW = 12'hf_f_0;
    localparam logic [11:0] COLOUR_MAGENTA = 12'hf_0_f;
    localparam logic [11:0] COLOUR_CYAN = 12'h0_f_f;

    localparam int HIT_WINDOW = 50;

    localparam ESC = 8'hff;
    localparam ENTER = 8'h0D;

endpackage