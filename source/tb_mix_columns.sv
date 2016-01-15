// $Id: $
// File name:   tb_mix_columns.sv
// Created:     12/1/2015
// Author:      Jeffrey Heath
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: test bench for mix columns
`timescale 1ns/10ps
module tb_mix_columns();
	reg [127:0] tb_data_in;
	reg [127:0] tb_data_out;
	reg [127:0] tb_data_in2;
	reg [127:0] tb_data_out2;
	int tb_test_num;

	//DUT portmap
	generate
	mix_columns DUT
	(
		.in(tb_data_in),
		.out(tb_data_out)
	);
	endgenerate

	//DUT portmap
	generate
	inv_mix_columns DUT2
	(
		.in(tb_data_in2),
		.out(tb_data_out2)
	);
	endgenerate

	//TEST BENCH MAIN PROCESS
	initial
	begin
		tb_test_num = 1;
		tb_data_in	= 128'h627a6f6644b109c82b18330a81c3b3e5;
		#2
		assert(tb_data_out == 128'h7b5b54657374566563746f725d53475d)
			else $error("output is wrong Test Case %d", tb_test_num);
		
		tb_test_num = 2;
		tb_data_in2	= 128'h8dcab9dc035006bc8f57161e00cafd8d;
		#2
		assert(tb_data_out2 == 128'hd635a667928b5eaeeec9cc3bc55f5777)
			else $error("output is wrong Test Case %d", tb_test_num);
	end
	 
endmodule
