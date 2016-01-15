// $Id: $
// File name:   flex_stp_sr.sv
// Created:     9/8/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Lab3 part 4.1 serial to parallel

module flex_stp_ring
#(
	parameter NUM_BITS = 4
)
(
	input wire clk, n_rst, shift_enable, clear,
	output reg [NUM_BITS-1:0] parallel_out
);
	
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (1'b0 == n_rst)
		begin
			parallel_out<=1;
		end
		else
		begin
			if (clear) parallel_out<=1;
			else if (shift_enable) parallel_out<={parallel_out[NUM_BITS-2:0],parallel_out[NUM_BITS-1]};
			else parallel_out<=parallel_out;
		end
	end
endmodule

			