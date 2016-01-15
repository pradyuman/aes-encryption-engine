// $Id: $
// File name:   edge_detect.sv
// Created:     10/5/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Edge detector copied mostly from startbit detector of Lab4.

module edge_detect
(
	input wire clk,n_rst,d_tk,
	output wire d_edge
);
	reg buffer;
	reg current;

	assign d_edge = (buffer!=current);
	
	always_ff @ (posedge clk, negedge n_rst)
	begin 
		if (1'b0 == n_rst)
		begin
			buffer<=1'b1;
			current<=1'b1;
		end
		else
		begin
			buffer<=d_tk;
			current<=buffer;
		end
	end

endmodule
