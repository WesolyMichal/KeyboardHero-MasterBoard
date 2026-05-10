import game_pkg::*;

module game_engine(
    input logic clk,
    input logic rst_n,
    input logic tick,

    input logic [5:0] buttons,
    input logic strum,

    input note_t note,
    output logic shift_note,
    output game_if game_data
);

endmodule