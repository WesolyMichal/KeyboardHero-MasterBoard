module UART_mux(
    input logic UART_select,
    input logic [7:0] fsm_data,
    input logic fsm_UART_send,
    input logic [7:0] game_data,
    input logic game_UART_send,

    output logic [7:0] UART_data,
    output logic UART_send
);

import game_pkg::*;

assign UART_data = (UART_select == UART_GAME) ? game_data : fsm_data;

assign UART_send = (UART_select == UART_GAME) ? game_UART_send : fsm_UART_send;

endmodule