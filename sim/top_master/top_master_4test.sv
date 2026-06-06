import game_pkg::*;

module top_master_4test(
    input logic clk40MHz,
    input logic rst_n,
    input logic [7:0] rx_data,
    input logic read_data,

    output logic [15:0] led,
    output logic uart_tx
);

wire navigation controls;

/*
 * Game Engine 
 */

game_if engine_out;

note_t note;
wire logic [7:0] note_addr;

wire logic [5:0] buttons;
wire logic strum;

/*
 * Outputs
 */

wire logic [7:0] UART_data, fsm_data;
wire logic UART_send, game_UART_send, fsm_UART_send, UART_select;

/*
 * FSM
 */

wire logic song_start, song_stop;
wire logic [1:0] song_select;

wire logic timer_enable, tick_orig, tick_decoder;

wire logic tx_empty;

assign led[7:0] = engine_out;

/*
 * Modules
 */

master_fsm u_master_fsm(
    .clk(clk40MHz),
    .rst_n,

    .engine(engine_out),

    .controls,

    .tx_empty,

    .song_start,
    .song_stop,
    .song_select,

    .timer_enable,

    .UART_data(fsm_data),
    .UART_send(fsm_UART_send),
    .UART_select
);


UART_mux u_UART_mux(
    .clk(clk40MHz),
    .rst_n,
    .UART_select,
    .fsm_data,
    .fsm_UART_send,
    .game_data(engine_out),
    .game_UART_send,
    .UART_data,
    .UART_send
);

uart #(.DVSR(1))u_UART_tx(
    .clk(clk40MHz),
    .reset(!rst_n),
    .wr_uart(UART_send),
    .w_data(UART_data),
    .tx(uart_tx),
    .tx_empty_out(tx_empty)
);

timer #(.FREQUENCY(160_000)) u_timer_1kHz(
    .clk(clk40MHz),
    .rst_n,
    .enable(timer_enable),
    .tick(tick_orig)
);

button_decoder u_button_decoder(
    .clk(clk40MHz),
    .rst_n,
    .tick_in(tick_orig),
    .rx_data,
    .read_data,
    .buttons,
    .strum,
    .controls,
    .tick_out(tick_decoder)
);

game_engine u_game_engine(
    .clk(clk40MHz),
    .rst_n,
    .tick_in(tick_decoder),
    .song_start,
    .song_stop,

    .note,
    .note_addr,

    .buttons,
    .strum,

    .game_data(engine_out),

    .UART_send(game_UART_send),

    .note_led(led[15:8])
);

song_rom u_song_rom(
    .clk(clk40MHz),
    .note,
    .note_addr,
    .song_select
);

endmodule