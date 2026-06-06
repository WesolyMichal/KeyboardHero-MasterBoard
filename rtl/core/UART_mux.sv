module UART_mux(
    input logic clk,
    input logic rst_n,

    input logic UART_select,
    input logic [7:0] fsm_data,
    input logic fsm_UART_send,
    input logic [7:0] game_data,
    input logic game_UART_send,

    output logic [7:0] UART_data,
    output logic UART_send
);

import game_pkg::*;

logic game_UART_send_buf;
logic [7:0] last_data;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        game_UART_send_buf <= '0;
        last_data <= '0;
    end else begin
        if((game_UART_send) && (game_data != last_data)) game_UART_send_buf <= 1'b1;
        else game_UART_send_buf <= 1'b0;
        last_data <= UART_data;
    end
end

assign UART_data = (UART_select == UART_GAME) ? game_data : fsm_data;

assign UART_send = (UART_select == UART_GAME) ? game_UART_send_buf : fsm_UART_send;

endmodule