// $Id: $
// File name:   addRoundKey.sv
// Created:     11/22/2015
// Author:      Jeffrey Heath
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: performs bitwise XOR on 128 bit input with roundKey
module addRoundKey(
	input wire [127:0] roundKey,
	input wire [127:0] data_in,
	output wire [127:0] data_out
);

		assign data_out = roundKey ^ data_in;

endmodule
