// $Id: $
// File name:   evolve_key_lib.sv
// Created:     11/23/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: wrapper for evolve key library

module evolve_key_lib(
	input wire [255:0] ks, [7:0] rconst,
	output wire [255:0] next_ks
);
	evolve_key_256 KEYSCH (
		.key_in(ks),
		.rconst(rconst),
		.key_out(next_ks)
	);

endmodule
