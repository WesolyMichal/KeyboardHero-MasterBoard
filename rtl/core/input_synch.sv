module input_synch(
    input logic clk40MHz,
    input logic clk100MHz,

    input logic rst_n,

    input logic read_data_100MHz,
    output logic read_data_40MHz
);

// --- Domena SZYBKA (100 MHz) ---
logic toggle_fast;
logic [2:0] sync_reg;
    
always_ff @(posedge clk100MHz or negedge rst_n) begin
    if(!rst_n) begin
        toggle_fast <= '0;    
    end else
        toggle_fast <= (read_data_100MHz) ? ~toggle_fast : toggle_fast; // Zmiana stanu 0->1 lub 1->0 przy każdym impulsie
end

// --- Domena WOLNA (40 MHz) ---


always_ff @(posedge clk40MHz or negedge rst_n) begin
    if(!rst_n) begin
        sync_reg <= '0;
    end else
    // Przesunięcie rejestru (podwójna synchronizacja + jeden krok do wykrycia zmiany)
    sync_reg <= {sync_reg[1:0], toggle_fast};
end

// Wykrycie zmiany stanu (Edge Detector na sygnale toggle)
// Jeśli bit 2 różni się od bitu 1, oznacza to, że nastąpiła zmiana w szybkiej domenie
assign read_data_40MHz = sync_reg[2] ^ sync_reg[1];

endmodule