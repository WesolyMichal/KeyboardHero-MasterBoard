import game_pkg::*;

module damped_comb(
    input game_if engine_out,
    output logic damped
);

assign damped = (engine_out.status == MISS);

endmodule