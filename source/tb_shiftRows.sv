// $Id: $
// File name:   tb_shiftRows.sv
// Created:     11/22/2015
// Author:      Jeffrey Heath
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: test bench for shiftrows
`timescale 1ns/10ps

module tb_shiftRows();

	reg [127:0] tb_data_in;
	reg [127:0] tb_data_out;
	integer tb_test_num;

	//DUT portmap
	generate
	shiftRows DUT
	(
		.data_in(tb_data_in),
		.data_out(tb_data_out)
	);
	endgenerate

	//TEST BENCH MAIN PROCESS
	initial
	begin
		tb_test_num = 1;
		tb_data_in	= 128'h7b5b54657374566563746f725d53475d;
		#1
		assert(tb_data_out == 128'h73744765635354655d5b56727b746f5d)
			else $error("output is wrong Test Case %d", tb_test_num);
	end
endmodule
