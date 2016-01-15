// $Id: $
// File name:   tb_subBytes.sv
// Created:     11/22/2015
// Author:      Jeffrey Heath
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: test bench for subBytes
`timescale 1ns/10ps

module tb_subBytes();

	reg [127:0] tb_data_in;
	reg [127:0] tb_data_out;
	int tb_test_num;

	//DUT portmap
	generate
	subBytes DUT
	(
		.data_in(tb_data_in),
		.data_out(tb_data_out)
	);
	endgenerate

	//TEST BENCH MAIN PROCESS
	initial
	begin
		tb_test_num = 1;
		tb_data_in	= 128'h73744765635354655d5b56727b746f5d;
		#2
		assert(tb_data_out == 128'h8f92a04dfbed204d4c39b1402192a84c)
			else $error("output is wrong Test Case %d", tb_test_num);
	$stop;
	end
endmodule
