// $Id: $
// File name:   tb_addRoundKey.sv
// Created:     11/22/2015
// Author:      Jeffrey Heath
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: test bench for addRoundKey
`timescale 1ns/10ps

module tb_addRoundKey();

	reg [127:0] tb_roundKey;
	reg [127:0] tb_data_in;
	reg [127:0] tb_data_out;
	integer tb_test_num;

	//DUT portmap
	generate
	addRoundKey DUT
	(
		.roundKey(tb_roundKey),
		.data_in(tb_data_in),
		.data_out(tb_data_out)
	);
	endgenerate

	//TEST BENCH MAIN PROCESS
	initial
	begin
		tb_test_num = 1;
		tb_roundKey = 128'h00000000000000000000000000000000;
		tb_data_in  = 128'habec860381611111abe000067830000c;
		#1
		assert(tb_data_out == 128'habec860381611111abe000067830000c)
			else $error("output is wrong Test Case %d", tb_test_num);
		tb_test_num += 1;
		tb_data_in = 128'h00000000000000000000000000000000;
		tb_roundKey  = 128'habec860381611111abe000067830000c;
		#1
		assert(tb_data_out == 128'habec860381611111abe000067830000c)
			else $error("output is wrong Test Case %d", tb_test_num);
		tb_test_num += 1;
		tb_data_in  = 128'h70b001506080c0300200b00c00ff0f0e;
		tb_roundKey = 128'habec8a0381611515bbe003067830000c;
		#1
		assert(tb_data_out == 128'hdb5c8b53e1e1d525b9e0b30a78cf0f02)
			else $error("output is wrong Test Case %d", tb_test_num);

		$stop;

	end

endmodule
