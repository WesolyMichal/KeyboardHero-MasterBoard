/*
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Michał Wesołowski
 *
 * Description:
 * Signal Decoder from PS2 Protocol
 */

import game_pkg::*;

module button_decoder(
    input logic clk,
    input logic rst_n,

    input logic read_data,
    input logic [7:0] rx_data,
    input logic tick_in,

    output logic [5:0] buttons,
    output logic strum,

    output navigation controls,

    output logic tick_out,

    input logic [5:0]board_switches,
    input logic board_strum,
    input logic board_esc,
    input logic board_enter,
    input logic board_next_song
);

logic released, released_nxt;

logic [5:0] buttons_nxt;
logic strum_nxt, tick_out_nxt;

logic [6:0] buffer, buffer_nxt;

navigation controls_nxt, con_pressed, con_pressed_nxt;

logic board_strum_db;
logic board_next_song_db;
logic board_esc_db;
logic board_enter_db;

debounce u_debounce_esc(
    .clk,
    .reset(!rst_n),
    .sw(board_esc),
    .db_tick(board_esc_db)
);

debounce u_debounce_enter(
    .clk,
    .reset(!rst_n),
    .sw(board_enter),
    .db_tick(board_enter_db)
);

debounce u_debounce_strum(
    .clk,
    .reset(!rst_n),
    .sw(board_strum),
    .db_tick(board_strum_db)
);

debounce u_debounce_next_song(
    .clk,
    .reset(!rst_n),
    .sw(board_next_song),
    .db_tick(board_next_song_db)
);

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        buttons     <= '0;
        strum       <= '0;
        controls    <= '0;
        con_pressed <= '0;
        tick_out    <= '0;
        buffer      <= '0;
        released    <= '0;
    end else begin
        buttons     <= buttons_nxt | board_switches;
        strum       <= strum_nxt | board_strum_db;
        controls.arr_left   <= controls_nxt.arr_left;
        controls.arr_right  <= controls_nxt.arr_right | board_next_song_db;
        controls.enter      <= controls_nxt.enter | board_enter_db;
        controls.esc        <= controls_nxt.esc | board_esc_db;
        con_pressed <= con_pressed_nxt;
        tick_out    <= tick_out_nxt;
        buffer      <= buffer_nxt;
        released    <= released_nxt;
    end
end



always_comb begin
    buffer_nxt = buffer;
    controls_nxt = '0;
    con_pressed_nxt = con_pressed;
    released_nxt = released;

    buttons_nxt = buttons;
    strum_nxt = strum;
    tick_out_nxt = '0;

    if(read_data) begin
        if(rx_data == RELEASED) released_nxt = '1;
        else released_nxt = '0;

        if(released) begin
            case(rx_data)
                ESC: begin
                    controls_nxt.esc = '0;
                    con_pressed_nxt.esc = '0;
                end
                ENTER : begin
                    controls_nxt.enter = '0;
                    con_pressed_nxt.enter = '0;
                end
                ARR_LEFT: begin
                    controls_nxt.arr_left = '0;
                    con_pressed_nxt.arr_left = '0;
                end
                ARR_RIGHT: begin
                    controls_nxt.arr_right = '0;
                    con_pressed_nxt.arr_right = '0;
                end
                BUTTON_1: buffer_nxt[0] = '0;
                BUTTON_2: buffer_nxt[1] = '0;
                BUTTON_3: buffer_nxt[2] = '0;
                BUTTON_4: buffer_nxt[3] = '0;
                BUTTON_5: buffer_nxt[4] = '0;
                BUTTON_6: buffer_nxt[5] = '0;
            endcase
        end else begin
            case(rx_data)
                ESC: begin
                    if(!con_pressed.esc) begin
                        controls_nxt.esc = '1;
                        con_pressed_nxt.esc = '1;
                    end
                end
                ENTER : begin
                    if(!con_pressed.enter) begin
                        controls_nxt.enter = '1;
                        con_pressed_nxt.enter = '1;
                    end
                end
                ARR_LEFT: begin
                    if(!con_pressed.arr_left) begin
                        controls_nxt.arr_left = '1;
                        con_pressed_nxt.arr_left = '1;
                    end
                end
                ARR_RIGHT: begin
                    if(!con_pressed.arr_right) begin
                        controls_nxt.arr_right = '1;
                        con_pressed_nxt.arr_right = '1;
                    end
                end
                BUTTON_1: buffer_nxt[0] = '1;
                BUTTON_2: buffer_nxt[1] = '1;
                BUTTON_3: buffer_nxt[2] = '1;
                BUTTON_4: buffer_nxt[3] = '1;
                BUTTON_5: buffer_nxt[4] = '1;
                BUTTON_6: buffer_nxt[5] = '1;
                STRUM:    buffer_nxt[6] = '1;
            endcase
        end
    end

    if(tick_in) begin
        {strum_nxt, buttons_nxt} = buffer;
        tick_out_nxt = '1;
        buffer_nxt[6] = '0;
    end
end

endmodule