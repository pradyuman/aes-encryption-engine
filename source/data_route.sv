// $Id: $
// File name:   data_route.sv
// Created:     11/16/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: router to determine which should be the input of aes


module data_route(
	input wire d_tk, [127:0] tk_in, a_out,
	output reg [127:0] aes_in
);
	always_comb 
	begin
		if (d_tk) aes_in = a_out;
		else aes_in = tk_in;
	end

endmodule 










	

