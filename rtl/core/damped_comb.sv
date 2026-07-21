/*
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Michał Wesołowski
 *
 * Description:
 * Damped sound signal logic
 */

import game_pkg::*;

module damped_comb(
    input game_if engine_out,
    output logic damped
);

assign damped = (engine_out.status == MISS);

endmodule