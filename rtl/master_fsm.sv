import game_pkg::*;

module master_fsm (
    input logic clk,
    input logic rst_n,
    
    input navigation controls,

    input game_if engine,

    output logic UART_send,

    output logic timer_enable,
    output logic [7:0] UART_data,
    output logic UART_select,

    output logic [1:0] song_select,
    output logic song_start,
    output logic song_stop
);

logic [7:0] UART_data_nxt;
logic [1:0] song_select_nxt;

logic UART_send_nxt;

logic timer_enable_nxt, UART_select_nxt, song_start_nxt, song_stop_nxt;

enum logic [3:0] {INIT, IDLE, SONG_CHOOSING, SONG_VERIF, SONG_PLAYING, END_SCREEN} state, state_nxt;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state           <= INIT;
        timer_enable    <= '0;
        UART_data       <= '0;
        UART_select     <= '0;
        UART_send       <= '0;
        song_select     <= '0;
        song_start      <= '0;
        song_stop       <= '1;
    end else begin
        state           <= state_nxt;
        timer_enable    <= timer_enable_nxt;
        UART_data       <= UART_data_nxt;
        UART_select     <= UART_select_nxt;
        UART_send       <= UART_send_nxt;
        song_start      <= song_start_nxt;
        song_stop       <= song_stop_nxt;
        song_select     <= song_select_nxt;
    end
end
    
always_comb begin
    timer_enable_nxt    = timer_enable;
    UART_data_nxt       = UART_data;
    UART_select_nxt     = UART_select;
    song_select_nxt     = song_select;
    song_start_nxt      = song_start;
    song_stop_nxt       = song_stop;
    UART_send_nxt       = '0;

    case(state)
        INIT: begin
            timer_enable_nxt    = '0;

            UART_data_nxt       = ENTER;
            UART_select_nxt     = UART_FSM;
            UART_send_nxt       = '1;

            song_select_nxt     = '0;
            song_start_nxt      = '0;
            song_stop_nxt       = '0;
        end
        IDLE: begin
            timer_enable_nxt    = '0;

            UART_data_nxt       = ENTER;
            UART_select_nxt     = UART_FSM;
            UART_send_nxt       = (controls.enter) ? '1 : '0;

            song_select_nxt     = '0;
            song_start_nxt      = '0;
            song_stop_nxt       = '0;
        end
        SONG_CHOOSING: begin
            timer_enable_nxt    = '0;

            UART_select_nxt     = UART_FSM;
            song_start_nxt      = '0;
            song_stop_nxt       = '0;

            if(controls.esc) begin
                song_select_nxt = 0;
                UART_data_nxt   = HALT;
                UART_send_nxt   = '1;
            end else if(controls.arr_right) begin 
                song_select_nxt = song_select + 1;
                UART_data_nxt   = {2'b0, (song_select + 1), CHOOSE};
                UART_send_nxt   = '1;
            end else if(controls.arr_left) begin 
                song_select_nxt = song_select - 1;
                UART_data_nxt   = {2'b0, (song_select - 1), CHOOSE};
                UART_send_nxt   = '1;
            end else if(controls.enter) begin
                song_select_nxt = song_select;
                UART_data_nxt   = {2'b0, song_select, CONFIRM};
                UART_send_nxt   = '1;
            end else begin
                song_select_nxt = song_select;
                UART_data_nxt   = UART_data;
                UART_send_nxt   = '0;
            end

        end
        SONG_VERIF: begin
            timer_enable_nxt = '1;

            UART_data_nxt = UART_data;
            UART_select_nxt = UART_GAME;
            UART_send_nxt = '0;

            song_select_nxt = song_select;
            song_stop_nxt = '0;
            
            song_start_nxt = '1;


        end

        SONG_PLAYING: begin
            if (controls.esc) begin
                timer_enable_nxt    = '0;

                UART_data_nxt       = HALT;
                UART_select_nxt     = UART_FSM;
                UART_send_nxt       = '1;

                song_select_nxt     = '0;
                song_start_nxt      = '0;
                song_stop_nxt       = '1;

            end else if(engine.status == END_GAME) begin
                timer_enable_nxt    = '0;

                UART_data_nxt       = '0;
                UART_select_nxt     = UART_FSM;

                song_select_nxt     = '0;
                song_start_nxt      = '0;
                song_stop_nxt       = '0;
            end else begin
                timer_enable_nxt    = '1;

                UART_data_nxt       = '0;
                UART_select_nxt     = UART_GAME;
                UART_send_nxt       = '0;
                
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

            if (controls.esc) begin
                UART_data_nxt = HALT;
                UART_send_nxt = '1;
            end else begin
                UART_data_nxt = '0;
                UART_send_nxt = '0;
            end
        end
    endcase
end

always_comb begin
    state_nxt = state;

    case(state)
        INIT: state_nxt = IDLE;
        IDLE: state_nxt = (controls.enter) ? SONG_CHOOSING : IDLE;
        SONG_CHOOSING: begin
            if(controls.enter) state_nxt = SONG_VERIF;
            else if(controls.esc) state_nxt = IDLE;
            else state_nxt = SONG_CHOOSING;
        end
        SONG_VERIF: begin
            state_nxt = SONG_PLAYING;
        end
        SONG_PLAYING: begin
            if(controls.esc) state_nxt = SONG_CHOOSING;
            else if(engine.status == END_GAME) state_nxt = END_SCREEN;
            else state_nxt = SONG_PLAYING;
        end
        END_SCREEN: begin
            if(controls.esc) state_nxt = SONG_CHOOSING;
            else state_nxt = END_SCREEN;
        end
    endcase
end

endmodule