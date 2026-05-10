package game_pkg;

    typedef struct packed {
        logic [15:0] duration;
        logic [15:0] waiting;
        logic [5:0] buttons;
        logic [5:0] long;
        logic [3:0] data;
    } note_t;

    typedef enum logic [1:0] {HIT, MISS, IDLE, END_GAME} game_action;

    typedef struct packed {
        logic [5:0] buttons;
        game_action status;
    } game_if;

    //COLOURS
    localparam logic [11:0] COLOUR_RED = 12'hf_0_0;
    localparam logic [11:0] COLOUR_GREEN = 12'h0_f_0;
    localparam logic [11:0] COLOUR_BLUE = 12'h0_0_f;
    localparam logic [11:0] COLOUR_YELLOW = 12'hf_f_0;
    localparam logic [11:0] COLOUR_MAGENTA = 12'hf_0_f;
    localparam logic [11:0] COLOUR_CYAN = 12'h0_f_f;

    //HIT MARGINS
    localparam HIT_MARGIN = 50;

    //KEY CODES - all are placeholders
    localparam ESC = 8'hff;
    localparam ENTER = 8'h0D;
    localparam ARR_LEFT = 8'h01;
    localparam ARR_RIGHT = 8'h02;

    localparam BUTTON_PRESS_1 = 8'h10;
    localparam BUTTON_PRESS_2 = 8'h20;
    localparam BUTTON_PRESS_3 = 8'h30;
    localparam BUTTON_PRESS_4 = 8'h40;
    localparam BUTTON_PRESS_5 = 8'h50;
    localparam BUTTON_PRESS_6 = 8'h60;
    localparam STRUM_PRESS = 8'h70;

    localparam BUTTON_RELEASE_1 = 8'hA0;
    localparam BUTTON_RELEASE_2 = 8'hB0;
    localparam BUTTON_RELEASE_3 = 8'hC0;
    localparam BUTTON_RELEASE_4 = 8'hD0;
    localparam BUTTON_RELEASE_5 = 8'hE0;
    localparam BUTTON_RELEASE_6 = 8'hF0;
    localparam STRUM_RELEASE = 8'h80;


    //SONG CHOOSING
    localparam CHOOSE = 4'hf;
    localparam CONFIRM = 4'hA;

    //UART SELECT
    localparam UART_FSM = 1'b0;
    localparam UART_GAME = 1'b1;

endpackage