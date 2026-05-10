module UART_mux(
    input logic UART_select,
    input logic [7:0] fsm_data,
    input logic [7:0] game_data,

    output logic [7:0] UART_data
);

import game_pkg::*;

assign UART_data = (UART_select == UART_GAME) ? game_data : fsm_data;

endmodule