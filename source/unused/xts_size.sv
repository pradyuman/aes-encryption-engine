// $Id: $
// File name:   xts_size.sv
// Created:     11/2/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: size for xts
module xts_size
(	
	input wire clk,n_rst,size_ud, is_valid,[127:0] data_in,
	output reg no_bytes, 
	output reg [6:0] last_size
);
	flex_counter #(121,0,0,0) upper(.clk(clk),.n_rst(n_rst),.load(size_ud),.clear(1'b0),.count_enable(is_valid),
				.rollover_val('1),.load_val(data_in[127:7]),.rollover_flag(no_bytes));

	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (1'b0 == n_rst)
		begin
			last_size<=0;
		end 
		else if (size_ud)
		begin
			last_size<=data_in[6:0];
		end
		else last_size<=last_size;
	end

endmodule
