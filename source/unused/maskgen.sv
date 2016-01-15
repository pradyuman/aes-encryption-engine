// $Id: $
// File name:   maskgen.sv
// Created:     11/2/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Generate a list of 1s as mask

module maskgen(
	input wire [6:0] last_size, 
	input wire no_bytes,
	output reg [127:0] mask
);
	always_comb 
	begin
	   if (no_bytes) mask = (2** last_size -1);
	   else mask = '0;
 
	end
	
endmodule
