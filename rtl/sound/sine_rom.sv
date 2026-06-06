module sine_rom(
    input logic [7:0] phase [0:2],
    output logic [7:0] value [0:2]
);

logic [7:0] sine [0:255] = {
    8'h80, 8'h83, 8'h86, 8'h89, 8'h8C, 8'h90, 8'h93, 8'h96,
    8'h99, 8'h9C, 8'h9F, 8'hA2, 8'hA5, 8'hA8, 8'hAB, 8'hAE,
    8'hB1, 8'hB3, 8'hB6, 8'hB9, 8'hBC, 8'hBF, 8'hC1, 8'hC4,
    8'hC7, 8'hC9, 8'hCC, 8'hCE, 8'hD1, 8'hD3, 8'hD5, 8'hD8,
    8'hDA, 8'hDC, 8'hDE, 8'hE0, 8'hE2, 8'hE4, 8'hE6, 8'hE8,
    8'hEA, 8'hEB, 8'hED, 8'hEF, 8'hF0, 8'hF1, 8'hF3, 8'hF4,
    8'hF5, 8'hF6, 8'hF8, 8'hF9, 8'hFA, 8'hFA, 8'hFB, 8'hFC,
    8'hFD, 8'hFD, 8'hFE, 8'hFE, 8'hFE, 8'hFF, 8'hFF, 8'hFF,
    8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFE, 8'hFE, 8'hFE, 8'hFD,
    8'hFD, 8'hFC, 8'hFB, 8'hFA, 8'hFA, 8'hF9, 8'hF8, 8'hF6,
    8'hF5, 8'hF4, 8'hF3, 8'hF1, 8'hF0, 8'hEF, 8'hED, 8'hEB,
    8'hEA, 8'hE8, 8'hE6, 8'hE4, 8'hE2, 8'hE0, 8'hDE, 8'hDC,
    8'hDA, 8'hD8, 8'hD5, 8'hD3, 8'hD1, 8'hCE, 8'hCC, 8'hC9,
    8'hC7, 8'hC4, 8'hC1, 8'hBF, 8'hBC, 8'hB9, 8'hB6, 8'hB3,
    8'hB1, 8'hAE, 8'hAB, 8'hA8, 8'hA5, 8'hA2, 8'h9F, 8'h9C,
    8'h99, 8'h96, 8'h93, 8'h90, 8'h8C, 8'h89, 8'h86, 8'h83,
    8'h80, 8'h7D, 8'h7A, 8'h77, 8'h74, 8'h70, 8'h6D, 8'h6A,
    8'h67, 8'h64, 8'h61, 8'h5E, 8'h5B, 8'h58, 8'h55, 8'h52,
    8'h4F, 8'h4D, 8'h4A, 8'h47, 8'h44, 8'h41, 8'h3F, 8'h3C,
    8'h39, 8'h37, 8'h34, 8'h32, 8'h2F, 8'h2D, 8'h2B, 8'h28,
    8'h26, 8'h24, 8'h22, 8'h20, 8'h1E, 8'h1C, 8'h1A, 8'h18,
    8'h16, 8'h15, 8'h13, 8'h11, 8'h10, 8'h0F, 8'h0D, 8'h0C,
    8'h0B, 8'h0A, 8'h08, 8'h07, 8'h06, 8'h06, 8'h05, 8'h04,
    8'h03, 8'h03, 8'h02, 8'h02, 8'h02, 8'h01, 8'h01, 8'h01,
    8'h01, 8'h01, 8'h01, 8'h01, 8'h02, 8'h02, 8'h02, 8'h03,
    8'h03, 8'h04, 8'h05, 8'h06, 8'h06, 8'h07, 8'h08, 8'h0A,
    8'h0B, 8'h0C, 8'h0D, 8'h0F, 8'h10, 8'h11, 8'h13, 8'h15,
    8'h16, 8'h18, 8'h1A, 8'h1C, 8'h1E, 8'h20, 8'h22, 8'h24,
    8'h26, 8'h28, 8'h2B, 8'h2D, 8'h2F, 8'h32, 8'h34, 8'h37,
    8'h39, 8'h3C, 8'h3F, 8'h41, 8'h44, 8'h47, 8'h4A, 8'h4D,
    8'h4F, 8'h52, 8'h55, 8'h58, 8'h5B, 8'h5E, 8'h61, 8'h64,
    8'h67, 8'h6A, 8'h6D, 8'h70, 8'h74, 8'h77, 8'h7A, 8'h7D
  };

always_comb begin
    value[0] = sine[phase[0]];
    value[1] = sine[phase[1]];
    value[2] = sine[phase[2]];
end

endmodule