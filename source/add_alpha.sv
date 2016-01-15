// $Id: $
// File name:   add_alpha.sv
// Created:     11/3/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: 256 xors

module add_alpha(
	input wire [127:0] oldalpha, alpha, aes_out,data_in,
	output wire [127:0] data_out, aes_in
);
	assign data_out = oldalpha ^ aes_out;
	assign aes_in = alpha ^ data_in;
endmodule 
	
