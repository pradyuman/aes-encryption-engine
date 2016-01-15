// $Id: $
// File name:   invSubBytes.sv
// Created:     11/22/2015
// Author:      Jeffrey Heath
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: inverse subBytes
module invSubBytes(
	input wire [127:0] data_in,
	output wire [127:0] data_out
);

	genvar i;
	generate
		for(i = 0; i < 16; i++)
		begin

			invSBox IX (.data_in(data_in[(i*8)+7:(i*8)]), .data_out(data_out[(i*8)+7:(i*8)]));
		end
	endgenerate

endmodule
