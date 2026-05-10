module button_buffer(
    input logic clk,
    input logic rst_n,

    input logic [7:0] msg,
    input logic enable,

    output logic [5:0] buttons,
    output logic strum,
    output logic tick
);

import game_pkg::*;

logic [5:0] buttons_nxt;
logic strum_nxt, tick_nxt;

logic [6:0] buffer;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        buttons <= '0;
        buffer <= '0;
        strum <= '0;
        tick <= '0;
    end else begin
        buttons <= buttons_nxt;
        strum <= strum_nxt;
        tick <= tick_nxt;

        case(msg)
            BUTTON_PRESS_1: buffer[0] <= 1'b1;
            BUTTON_PRESS_2: buffer[1] <= 1'b1;
            BUTTON_PRESS_3: buffer[2] <= 1'b1;
            BUTTON_PRESS_4: buffer[3] <= 1'b1;
            BUTTON_PRESS_5: buffer[4] <= 1'b1;
            BUTTON_PRESS_6: buffer[5] <= 1'b1;
            STRUM_PRESS:    buffer[6] <= 1'b1;
        
            BUTTON_RELEASE_1: buffer[0] <= 1'b0;
            BUTTON_RELEASE_2: buffer[1] <= 1'b0;
            BUTTON_RELEASE_3: buffer[2] <= 1'b0;
            BUTTON_RELEASE_4: buffer[3] <= 1'b0;
            BUTTON_RELEASE_5: buffer[4] <= 1'b0;
            BUTTON_RELEASE_6: buffer[5] <= 1'b0;
            STRUM_RELEASE:    buffer[6] <= 1'b0;
        endcase

    end
end

always_comb begin
    buttons_nxt = buttons;
    strum_nxt = strum;
    tick_nxt = tick;

    if(enable) begin
        buttons_nxt = buffer[5:0];
        strum_nxt = buffer[6];
        tick_nxt = 1'b1;
    end else tick_nxt = 1'b0;
end

endmodule