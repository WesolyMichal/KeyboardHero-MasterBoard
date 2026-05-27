import game_pkg::*;

module top_master(
    input logic clk40MHz,
    input logic clk100MHz,
    input logic PS2_clk,
    input logic PS2_data,
    input logic rst_n,

    output logic [7:0] led,
    output logic uart_tx
);

/*
 *  PS2 data
 */ 
wire logic [7:0] rx_data;
wire logic read_data_100MHz;
wire logic read_data_40MHz;

wire navigation controls;

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
wire logic UART_send, game_UART_send, fsm_UART_send, UART_select;

/*
 * FSM
 */

wire logic song_start, song_stop;
wire logic [3:0] song_select;

wire logic timer_enable, decoder_enable;

assign led = engine_out;

/*
 * Modules
 */

master_fsm u_master_fsm(
    .clk(clk40MHz),
    .rst_n,

    .engine(engine_out),

    .controls,

    .song_start,
    .song_stop,
    .song_select,

    .timer_enable,

    .UART_data(fsm_data),
    .UART_send(fsm_UART_send),
    .UART_select
);

Ps2Interface u_Ps2Interface(
    .clk(clk100MHz),
    .ps2_clk(PS2_clk),
    .ps2_data(PS2_data),
    .rst(!rst_n),
    .rx_data,
    .read_data(read_data_100MHz)
);

UART_mux u_UART_mux(
    .UART_select,
    .fsm_data,
    .fsm_UART_send,
    .game_data(engine_out),
    .game_UART_send,
    .UART_data,
    .UART_send
);

uart u_UART_tx(
    .clk(clk40MHz),
    .reset(!rst_n),
    .wr_uart(UART_send),
    .w_data(UART_data),
    .tx(uart_tx)
);

timer #(.FREQUENCY(1000)) u_timer_1kHz(
    .clk(clk40MHz),
    .rst_n,
    .enable(timer_enable),
    .overflow(decoder_enable)
);

input_synch u_input_synch(
    .clk40MHz,
    .clk100MHz,
    .rst_n,

    .read_data_100MHz,
    .read_data_40MHz
);

button_decoder u_button_decoder(
    .clk(clk40MHz),
    .rst_n,
    .enable(decoder_enable),
    .rx_data,
    .read_data(read_data_40MHz),
    .buttons,
    .strum,
    .controls,
    .tick
);

game_engine u_game_engine(
    .clk(clk40MHz),
    .rst_n,
    .tick,
    .song_start,
    .song_stop,

    .note,
    .note_addr,

    .buttons,
    .strum,

    .game_data(engine_out),

    .UART_send(game_UART_send)
);

song_rom u_song_rom(
    .clk(clk40MHz),
    .note,
    .note_addr,
    .song_select
);

endmodule