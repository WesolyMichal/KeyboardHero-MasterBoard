import sound_pkg::*;

module mixer #(
    parameter logic [3:0] NOTES = 3
)(
    input logic clk,
    input logic rst_n,

    input logic damped,

    input pmod_internal pmod_in,
    output pmod_internal pmod_out,

    input note_enum notes_in [0:NOTES-1],
    input logic [7:0] value_in [0:NOTES-1],

    output logic [7:0] value_out
);

logic [7:0] value_out_nxt;
logic [(NOTES * 8)-1:0] value_sum;

logic [3:0] active_freqs;



always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        value_out <= '0;
        pmod_out <= '0;
    end else begin
        value_out <= value_out_nxt;
        pmod_out <= pmod_in;
    end
end

always_comb begin

    value_sum = '0;
    active_freqs = '0;
    for(logic [3:0] harmonic = 0; harmonic < NOTES; harmonic++) begin
        if(notes_in[harmonic] != SILENCE) begin
            active_freqs++;
            value_sum = value_sum + value_in[harmonic];
        end
    end

    if(active_freqs != 0) value_out_nxt = 8'(value_sum / active_freqs) >> 1'(damped);
    else value_out_nxt = 8'h80;
    
end

endmodule