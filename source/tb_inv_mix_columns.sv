// $Id: $
// File name:   tb_inv_mix_columns.sv
// Created:     12/2/2015
// Author:      Jeffrey Heath
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: test bench for inv_mix_columns
`timescale 1ns/10ps
module tb_inv_mix_columns();
	reg [127:0] tb_data_in;
	reg [127:0] tb_data_out;
	int tb_test_num;

	//DUT portmap
	generate
	inv_mix_columns DUT
	(
		.in(tb_data_in),
		.out(tb_data_out)
	);
	endgenerate

	//TEST BENCH MAIN PROCESS
	initial
	begin
		tb_test_num = 1;
		tb_data_in	= 128'h8dcab9dc035006bc8f57161e00cafd8d);
		#2
		assert(tb_data_out == 128'hd635a667928b5eaeeec9cc3bc55f5777)
			else $error("output is wrong Test Case %d", tb_test_num);
	end
	 
endmodule