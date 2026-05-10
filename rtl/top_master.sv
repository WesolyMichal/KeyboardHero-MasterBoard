import game_pkg::*;

module top_master(
    input logic clk,
    input logic rst_n,

    output logic uart_tx
);

game_if engine_out;

note_t note;
wire logic [7:0] note_addr;

wire logic [7:0] UART_data, fsm_data;
wire logic UART_ready, UART_select;

wire logic song_start, song_stop;
wire logic [3:0] song_select;

wire logic timer_enable, buffer_enable;
wire logic [7:0] key;

wire logic [5:0] buttons;
wire logic strum;
wire logic tick;

master_fsm u_master_fsm(
    .clk,
    .rst_n,
    .engine(engine_out),

    .song_start,
    .song_stop,
    .song_select,

    .timer_enable,

    .UART_data(fsm_data),
    .UART_ready,
    .UART_select,

    .key
);

UART_mux u_UART_mux(
    .UART_select,
    .fsm_data,
    .game_data(engine_out),
    .UART_data
);

timer #(.FREQUENCY(1000)) u_timer_1kHz(
    .clk,
    .rst_n,
    .enable(timer_enable),
    .overflow(buffer_enable)
);

button_buffer u_button_buffer(
    .clk,
    .rst_n,
    .enable(buffer_enable),
    .msg(key),
    .buttons,
    .strum,
    .tick
);

game_engine u_game_engine(
    .clk,
    .rst_n,
    .tick,
    .song_start,

    .note,
    .note_addr,

    .buttons,
    .strum,

    .game_data(engine_out)
);

song_rom u_song_rom(
    .clk,
    .note,
    .note_addr,
    .song_select
);

endmodule