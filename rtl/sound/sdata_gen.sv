import sound_pkg::*;

module sdata_gen(
    input logic clk,
    input logic rst_n,

    input logic [RESOLUTION_BITS-1:0] r_data,
    input logic [RESOLUTION_BITS-1:0] l_data,

    input pmod_internal pmod_in,

    output pmod_if pmod_out
);

pmod_if pmod_out_nxt;

logic lrclk_edge, bclk_posedge;

// ZMIANA: Zwiększony licznik, aby bezpiecznie obsługiwał wartości do 31
logic [5:0] bit_counter, bit_counter_nxt;

// ZMIANA: Bufor przechowuje pełne 32-bitowe słowo wyjściowe I2S
logic [31:0] current_data, current_data_nxt;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pmod_out.bclk  <= '0;
        pmod_out.lrclk <= '0;
        pmod_out.sdata <= '0;
        pmod_out.shutdown_n <= '0;
        bit_counter <= '0;
        current_data <= '0;
    end else begin
        pmod_out.bclk  <= pmod_out_nxt.bclk;
        pmod_out.lrclk <= pmod_out_nxt.lrclk;
        pmod_out.sdata <= pmod_out_nxt.sdata;
        pmod_out.shutdown_n <= '1;

        bit_counter <= bit_counter_nxt;
        current_data <= current_data_nxt;
    end
end

assign pmod_out.mclk_e = clk;

always_comb begin
    pmod_out_nxt.bclk = pmod_in.bclk;
    pmod_out_nxt.lrclk = pmod_in.lrclk;
    pmod_out_nxt.mclk_e = clk;

    pmod_out_nxt.sdata = pmod_out.sdata;
    current_data_nxt = current_data;
    bit_counter_nxt = bit_counter;

    lrclk_edge = (pmod_in.lrclk != pmod_out.lrclk);
    bclk_posedge = (pmod_out.bclk == 1'b0) && (pmod_in.bclk == 1'b1);

    if(pmod_in.enable) begin
        if(bclk_posedge) begin
            if(lrclk_edge) begin
                // ZMIANA: Na zboczu LRCLK nie wystawiamy jeszcze bitu danych (I2S delay).
                // Przygotowujemy całą ramkę 32-bitową: dane l/r lądują na najwyższych bitach, reszta to 0.
                case(pmod_in.lrclk)
                    1'b0: begin
                        current_data_nxt = {l_data, {(32-RESOLUTION_BITS){1'b0}}};
                        pmod_out_nxt.sdata = pmod_out.sdata; // trzymaj poprzedni stan przez 1 takt BCLK
                        bit_counter_nxt = 6'd31;             // ustawiamy licznik na początek 32-bitowego okna
                    end
                    1'b1: begin
                        current_data_nxt = {r_data, {(32-RESOLUTION_BITS){1'b0}}};
                        pmod_out_nxt.sdata = pmod_out.sdata; // trzymaj poprzedni stan przez 1 takt BCLK
                        bit_counter_nxt = 6'd31;             // ustawiamy licznik na początek 32-bitowego okna
                    end
                endcase
            end else begin
                // ZMIANA: Wysyłamy bit o indeksie wskazywanym przez licznik i zmniejszamy go.
                // Dzięki temu MSB poleci dokładnie 1 takt BCLK po zmianie LRCLK.
                pmod_out_nxt.sdata = current_data[bit_counter];
                
                if (bit_counter > 0) begin
                    bit_counter_nxt = bit_counter - 1;
                end else begin
                    bit_counter_nxt = '0; // zabezpieczenie przed przepełnieniem, gdyby okno miało > 32 bity
                end
            end
        end
    end else begin
        current_data_nxt = '0;
        pmod_out_nxt.sdata = '0;
        bit_counter_nxt = '0;
    end
end

endmodule