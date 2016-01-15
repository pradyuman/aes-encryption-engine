// $Id: $
// File name:   tb_invSubBytes.sv
// Created:     11/22/2015
// Author:      Jeffrey Heath
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: test bench for invSubBytes
`timescale 1ns/10ps

module tb_invSubBytes();

	reg [127:0] tb_data_in;
	reg [127:0] tb_data_out;
	integer tb_test_num;

	//DUT portmap
	generate
	invSubBytes DUT
	(
		.data_in(tb_data_in),
		.data_out(tb_data_out)
	);
	endgenerate

	//TEST BENCH MAIN PROCESS
	initial
	begin
		tb_test_num = 1;
		tb_data_in	= 128'h5d7456657b536f65735b47726374545d;
		#2
		assert(tb_data_out == 128'h8dcab9bc035006bc8f57161e00cafd8d)
			else $error("output is wrong Test Case %d", tb_test_num);
	end
endmodule
