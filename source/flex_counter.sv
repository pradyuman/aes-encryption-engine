// $Id: $
// File name:   flex_counter.sv
// Created:     9/9/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.2  Customized reset value!!!
// Description: flexible and scalable counter with rollover for Lab3 part5
`timescale 1ns / 10ps
module flex_counter
#(
	parameter NUM_CNT_BITS = 4,
	parameter CLEAR_TO = 0,
	parameter RESET_TO = 0
)
(
	input wire clk,n_rst,clear,count_enable,[NUM_CNT_BITS-1:0] rollover_val,
	output reg [NUM_CNT_BITS-1:0] count_out,
	output reg rollover_flag
);

	reg [NUM_CNT_BITS-1:0] ffs;

	assign count_out = ffs;
	/*
	always @ (rollover_val)
	begin
		#(1ns)
		assert((rollover_val>1)||(!count_enable))
		else $error("rollover too small");
	end
*/
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (1'b0 == n_rst)
		begin
			ffs<=RESET_TO;
			rollover_flag<=0;
		end
		else
		begin
			if (clear)
			begin
				ffs<=CLEAR_TO;
				rollover_flag<=(CLEAR_TO==rollover_val);
			end
			else
			begin
				if (rollover_flag)
				begin
					ffs<=1;
					rollover_flag<=0;
				end
				else if (count_enable)
				begin
					ffs<=ffs+1;
					rollover_flag<=((rollover_val-1)==ffs);
				end
				else
				begin
					ffs<=ffs;
					rollover_flag<=rollover_flag;
				end
			end
		end
	end
endmodule
