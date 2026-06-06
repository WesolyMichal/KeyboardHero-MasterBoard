import sound_pkg::*;

module phase_inc_rom #(
    parameter [3:0] NOTES = 3
)(
    input note_enum note_index [0:NOTES-1],
    output logic [23:0] phase_shift[0:NOTES-1]
);

logic [23:0] note_inc_table [0:49] = {
    24'd0,     // SILENCE
    24'd24882, // C2
    24'd26362, // C#2
    24'd27930, // D2
    24'd29590, // D#2
    24'd31350, // E2
    24'd33214, // F2
    24'd35189, // F#2
    24'd37282, // G2
    24'd39499, // G#2
    24'd41847, // A2
    24'd44336, // A#2
    24'd46972, // B2
    24'd49765, // C3
    24'd52725, // C#3
    24'd55860, // D3
    24'd59181, // D#3
    24'd62701, // E3
    24'd66429, // F3 
    24'd70379, // F#3
    24'd74564, // G3
    24'd78998, // G#3
    24'd83695, // A3
    24'd88672, // A#3
    24'd93945, // B3
    24'd99531, // C4
    24'd105450,// C#4
    24'd111720,// D4
    24'd118363,// D#4
    24'd125402,// E4
    24'd132858,// F4
    24'd140759,// F#4
    24'd149129,// G4
    24'd157996,// G#4
    24'd167391,// A4
    24'd177345,// A#4
    24'd187890,// B4
    24'd199063,// C5
    24'd210900,// C#5
    24'd223441,// D5
    24'd236727,// D#5
    24'd250804,// E5
    24'd265717,// F5
    24'd281518,// F#5
    24'd298258,// G5
    24'd315993,// G#5
    24'd334783,// A5
    24'd354690,// A#5
    24'd375781,// B5
    24'd398126 // C6
};

always_comb begin
    for(logic [3:0] harmonic = 0; harmonic < NOTES; harmonic++) begin
        if( 6'(note_index[harmonic] ) > 49) phase_shift[harmonic] = 0;
        else phase_shift[harmonic] = note_inc_table[note_index[harmonic]];
    end
end

endmodule