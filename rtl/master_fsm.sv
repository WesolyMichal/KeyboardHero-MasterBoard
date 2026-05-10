import game_pkg::*;

module master_fsm (
    input logic clk,
    input logic rst_n,

    input logic [7:0] key,
    input game_status engine,

    input logic UART_ready,

    output logic timer_enable,
    output logic [7:0] UART_data,
    output logic UART_select,

    output logic [3:0] song_select,
    output logic song_start,
    output logic song_stop
);

logic [7:0] UART_data_nxt;
logic [3:0] song_select_nxt;

logic timer_enable_nxt, UART_select_nxt, song_start_nxt, song_stop_nxt;

enum logic [3:0] {INIT, IDLE, SONG_CHOOSING, SONG_VERIF, SONG_PLAYING, END_SCREEN} state, state_nxt;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state           <= IDLE;
        timer_enable    <= '0;
        UART_data       <= '0;
        UART_select     <= '0;
        song_select     <= '0;
        song_start      <= '0;
        song_stop       <= '1;
    end else begin
        state           <= state_nxt;
        timer_enable    <= timer_enable_nxt;
        UART_data       <= UART_data_nxt;
        UART_select     <= UART_select_nxt;
        song_select     <= song_select_nxt;
        song_start      <= song_start_nxt;
        song_stop       <= song_stop_nxt;
    end
end
    
always_comb begin
    timer_enable_nxt    = timer_enable;
    UART_data_nxt       = UART_data;
    UART_select_nxt     = UART_select;
    song_select_nxt     = song_select;
    song_start_nxt      = song_start;
    song_stop_nxt       = song_stop;

    case(state)
        INIT: begin
            UART_select_nxt = '0;
            UART_data_nxt = ENTER; //placeholder
            state_nxt = IDLE;
        end
        IDLE: begin
            UART_data_nxt = 8'h00;
            state_nxt = IDLE;
            if(key == ENTER) begin
                state_nxt = SONG_CHOOSING;
                UART_data_nxt = ENTER;
            end
        end
        SONG_CHOOSING: begin
            UART_data_nxt = 8'h00;
            state_nxt = IDLE;
            if(key == 8'h01) begin //placeholder
                song_select_nxt = song_select + 1;
                UART_data_nxt = {(song_select + 1), 4'hf}; //placeholder
            end else if(key == 8'h02) begin //placeholder
                song_select_nxt = song_select - 1;
                UART_data_nxt = {(song_select - 1), 4'hf}; //placeholder
            end else if(key == ENTER) begin //placeholder
                state_nxt = SONG_VERIF;
            end else if(key == ESC) begin
                state_nxt = IDLE;
                UART_data_nxt = ESC;
            end
        end
        SONG_VERIF: begin
            UART_data_nxt = {(song_select - 1), 4'hA};
            if(UART_ready == '1) begin
                state_nxt = SONG_PLAYING;
                song_start_nxt = '1;
                UART_select_nxt = '1;
            end else begin
                state_nxt = SONG_VERIF;
                song_start_nxt = '0;
                UART_select_nxt = '0;
            end
        end
        SONG_PLAYING: begin
            UART_data_nxt = 8'h00;
            timer_enable_nxt = '1;
            song_start_nxt = '0;
            if ((key == ESC) || (engine.status == STOP)) begin
                timer_enable_nxt = '0;
                UART_select_nxt = '0;
                song_stop_nxt = '1;
                song_select_nxt = '0;
                state_nxt = IDLE;
            end else if(engine.status == END_GAME) begin
                timer_enable_nxt = '0;
                UART_select_nxt = '0;
                song_select_nxt = '0;
                song_select_nxt = '0;
                state_nxt = END_SCREEN;
            end else begin
                UART_select_nxt = '1;
                song_stop_nxt = '0;
                state_nxt = SONG_PLAYING;
            end
        end
        END_SCREEN: begin
            UART_data_nxt = 8'h00;
            if (key == ESC) begin
                state_nxt = SONG_CHOOSING;
                UART_data_nxt = ESC;
            end
        end
    endcase
end

endmodule