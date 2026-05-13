import game_pkg::*;

module master_fsm (
    input logic clk,
    input logic rst_n,

    input logic [7:0] key,
    input game_if engine,

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
            timer_enable_nxt    = '0;
            UART_data_nxt       = ENTER;
            UART_select_nxt     = UART_FSM;
            song_select_nxt     = '0;
            song_start_nxt      = '0;
            song_stop_nxt       = '0;
        end
        IDLE: begin
            timer_enable_nxt    = '0;
            UART_data_nxt       = '0;
            UART_select_nxt     = UART_FSM;
            song_select_nxt     = '0;
            song_start_nxt      = '0;
            song_stop_nxt       = '0;
        end
        SONG_CHOOSING: begin
            timer_enable_nxt    = '0;
            UART_select_nxt     = UART_FSM;
            song_start_nxt      = '0;
            song_stop_nxt       = '0;

            if(key == ARR_RIGHT) begin 
                song_select_nxt = song_select + 1;
                UART_data_nxt = {(song_select + 1), CHOOSE}; 
            end else if(key == ARR_LEFT) begin 
                song_select_nxt = song_select - 1;
                UART_data_nxt = {(song_select - 1), CHOOSE};
            end else begin
                song_select_nxt = song_select;
                UART_data_nxt = UART_data;
            end

        end
        SONG_VERIF: begin
            timer_enable_nxt    = '0;
            UART_data_nxt       = {song_select, CONFIRM};
            song_select_nxt     = song_select;
            song_stop_nxt       = '0;
            
            if(UART_ready == '1) begin
                song_start_nxt = '1;
                UART_select_nxt = UART_GAME;
            end else begin
                song_start_nxt = '0;
                UART_select_nxt = UART_FSM;
            end
        end

        SONG_PLAYING: begin
            if (key == ESC) begin
                timer_enable_nxt    = '0;
                UART_data_nxt       =  8'hAF; //placeholder
                UART_select_nxt     = UART_FSM;
                song_select_nxt     = '0;
                song_start_nxt      = '0;
                song_stop_nxt       = '1;
            end else if(engine.status == END_GAME) begin
                timer_enable_nxt    = '0;
                UART_data_nxt       = '0;
                UART_select_nxt     = UART_FSM;
                song_select_nxt     = '0;
                song_start_nxt      = '0;
                song_stop_nxt       = '1; //nie wiem, czy to potrzebne
            end else begin
                timer_enable_nxt    = '1;
                UART_data_nxt       = '0;
                UART_select_nxt     = UART_GAME;
                song_select_nxt     = song_select;
                song_start_nxt      = '0;
                song_stop_nxt       = '0;
            end
        end
        END_SCREEN: begin
            timer_enable_nxt    = '0;
            UART_select_nxt     = UART_FSM;
            song_select_nxt     = '0;
            song_start_nxt      = '0;
            song_stop_nxt       = '0;

            if (key == ESC) UART_data_nxt = ESC;
            else UART_data_nxt = '0;
        end
    endcase
end

always_comb begin
    state_nxt = state;

    case(state)
        INIT: state_nxt = IDLE;
        IDLE: state_nxt = (key == ENTER) ? SONG_CHOOSING : IDLE;
        SONG_CHOOSING: begin
            if(key == ENTER) state_nxt = SONG_VERIF;
            else if(key == ESC) state_nxt = IDLE;
            else state_nxt = SONG_CHOOSING;
        end
        SONG_VERIF: begin
            if(UART_ready == '1) state_nxt = SONG_PLAYING;
            else state_nxt = SONG_VERIF;
        end
        SONG_PLAYING: begin
            if(key == ESC) state_nxt = SONG_CHOOSING;
            else if(engine.status == END_GAME) state_nxt = END_SCREEN;
            else state_nxt = SONG_PLAYING;
        end
        END_SCREEN: begin
            if(key == ESC) state_nxt = SONG_CHOOSING;
            else state_nxt = END_SCREEN;
        end
    endcase
end

endmodule