import sound_pkg::*;

module phase_acc_note #(
    parameter logic [3:0] NOTES = 3
)(
    input logic clk,
    input logic rst_n,

    input note_enum notes_in [0:NOTES-1],

    input logic [23:0] phase_shift [0:NOTES-1],

    input pmod_internal pmod_in,
    output pmod_internal pmod_out,
    
    output logic [7:0] phase [0:NOTES-1],
    output note_enum notes_out [0:NOTES-1]
);

/*
 * M = f_in * 2^N / f_sample
 * f_sample = 44,1kHz
 * N = 24, 2^N = 16 777 216
 * M = 380,44 ~ 380
 */ 

logic [23:0] phase_acc [0:NOTES-1], phase_inc [0:NOTES-1];
logic lrclk_posedge;

always_comb begin

    for(logic [3:0]harmonic = 0; harmonic < NOTES; harmonic++) begin

        phase_inc[harmonic] = phase_shift[harmonic];

    end

    lrclk_posedge = (pmod_in.lrclk == 1'b1) && (pmod_out.lrclk == 1'b0);
end

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin

        for(logic [3:0] harmonic = 0; harmonic < NOTES; harmonic++) begin
            phase_acc[harmonic] <= '0;
            notes_out[harmonic] <= SILENCE;
        end

        pmod_out <= '0;

    end else begin

        if(lrclk_posedge) 

            for(logic [3:0]harmonic = 0; harmonic < NOTES; harmonic++)
                phase_acc[harmonic] <= phase_acc[harmonic] + phase_inc[harmonic];

        else phase_acc <= phase_acc;

        pmod_out <= pmod_in;
        notes_out <= notes_in;
    end
end

always_comb 
    for(logic [3:0]harmonic = 0; harmonic < NOTES; harmonic++) 
        phase[harmonic] = phase_acc[harmonic][23:16];

endmodule