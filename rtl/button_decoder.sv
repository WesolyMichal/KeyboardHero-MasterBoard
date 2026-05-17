import game_pkg::*;

module button_decoder(
    input logic clk,
    input logic rst_n,

    input logic read_data,
    input logic [7:0] rx_data,
    input logic enable,

    output logic [5:0] buttons,
    output logic strum,

    output navigation controls,

    output logic tick
);

logic released, released_nxt;

logic [5:0] buttons_nxt;
logic strum_nxt, tick_nxt;

logic [6:0] buffer, buffer_nxt;

navigation controls_nxt, con_pressed, con_pressed_nxt;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        buttons     <= '0;
        strum       <= '0;
        controls    <= '0;
        con_pressed <= '0;
        tick        <= '0;
        buffer      <= '0;
        released    <= '0;
    end else begin
        buttons     <= buttons_nxt;
        strum       <= strum_nxt;
        controls    <= controls_nxt;
        con_pressed <= con_pressed_nxt;
        tick        <= tick_nxt;
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
    tick_nxt = '0;

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

    if(enable) begin
        {strum_nxt, buttons_nxt} = buffer;
        tick_nxt = '1;
        buffer_nxt[6] = '0;
    end
end

endmodule