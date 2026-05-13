import game_pkg::*;

module top_master(
    input logic clk40MHz,
    input logic clk100MHz,
    input logic PS2_clk,
    input logic PS2_data,
    input logic rst_n,

    output logic uart_tx
);

/*
 *  PS2 data
 */ 
wire logic [7:0] rx_data;
wire logic read_data;

wire logic [7:0] key;

/*
 * Game Engine 
 */

game_if engine_out;

note_t note;
wire logic [7:0] note_addr;

wire logic [5:0] buttons;
wire logic strum;
wire logic tick;

/*
 * Outputs
 */

wire logic [7:0] UART_data, fsm_data;
wire logic UART_ready, UART_select;

/*
 * FSM
 */

wire logic song_start, song_stop;
wire logic [3:0] song_select;

wire logic timer_enable, decoder_enable;

/*
 * Modules
 */

master_fsm u_master_fsm(
    .clk(clk40MHz),
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

Ps2Interface u_Ps2Interface(
    .clk(clk100MHz),
    .ps2_clk(PS2_clk),
    .ps2_data(PS2_data),
    .rst(!rst_n),
    .rx_data,
    .read_data
);

key_buffer u_key_buffer(
    .clk(clk40MHz),
    .rst_n,
    .rx_data,
    .read_data,
    .key
);

UART_mux u_UART_mux(
    .UART_select,
    .fsm_data,
    .game_data(engine_out),
    .UART_data
);

timer #(.FREQUENCY(1000)) u_timer_1kHz(
    .clk(clk40MHz),
    .rst_n,
    .enable(timer_enable),
    .overflow(decoder_enable)
);

button_decoder u_button_decoder(
    .clk(clk40MHz),
    .rst_n,
    .enable(decoder_enable),
    .msg(key),
    .buttons,
    .strum,
    .tick
);

game_engine u_game_engine(
    .clk(clk40MHz),
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
    .clk(clk40MHz),
    .note,
    .note_addr,
    .song_select
);

endmodule