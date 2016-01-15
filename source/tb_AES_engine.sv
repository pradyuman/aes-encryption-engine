// $Id: $
// File name:   tb_AES_engine.sv
// Created:     12/1/2015
// Author:      Jeffrey Heath
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: test bench for high level AES_engine
`timescale 1ns/10ps
module tb_AES_engine();
	//DEFINE LOCAL CONSTANTS
	localparam CLK_PERIOD = 5; //200MHz

	//DECLARE LOCAL VARIABLES
	reg tb_clk;
	reg tb_n_rst;
	reg tb_encrypt_flag;
	reg [127:0] tb_data_in;
	reg tb_is_valid;
	reg [3:0] tb_round_number;
	reg tb_load;
	reg [127:0] tb_key;
	reg tb_busy_out;
	reg tb_ready_out;
	reg [127:0] tb_data_out;
	reg [127:0] expected_data_out;
	reg expected_busy_out;
	reg expected_ready_out;

	//DECLARE TEST BENCH SIGNALS
	integer testcase;

	//clock generation block 200MHz
	always begin
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD / 2.0);
	end
	
	//DUT PORT MAP
	AES_engine DUT(.clk(tb_clk), .n_rst(tb_n_rst), .data_in(tb_data_in), .encrypt_flag(tb_encrypt_flag), .round_number(tb_round_number), .load(tb_load), .key(tb_key), .busy_out(tb_busy_out), .ready(tb_ready_out), .data_out(tb_data_out), .is_valid(tb_is_valid));

	//RESET DUT
	task reset_dut;
	begin
		//activate reset
		tb_n_rst = 1'b0;
		//wait a couple clock cycles
		@(posedge tb_clk);
		@(posedge tb_clk);
		//release reset
		@(negedge tb_clk);
		tb_n_rst = 1;

		//wait before reactivating design
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		
	end
	endtask

	//CHECK DATA_OUT VALUE
	task check_output;
	begin
		assert(tb_data_out == expected_data_out)
		else $error("ERROR testcase %d: data_out does not match. expected: %d, actual: %d", testcase, expected_data_out, tb_data_out);
		assert(tb_busy_out == expected_busy_out)
		else $error("ERROR testcase %d: busy_out does not match. expected: %d, actual: %d", testcase, expected_busy_out, tb_busy_out);
		assert(tb_ready_out == expected_ready_out)
		else $error("ERROR testcase %d: ready_out does not match. expected: %d, actual: %d", testcase, expected_ready_out, tb_ready_out);
	end
	endtask

	//TESTCASES
	initial
	begin
		testcase = 1;
		expected_data_out = 128'h997a616dad216ab0320db5c848e02996;
		expected_busy_out = 1'b0;
		expected_ready_out = 1;
		tb_is_valid = 1'b0;
		reset_dut;
		//LOAD KEYS
		//key0
		tb_round_number = 4'd0;
		tb_key = 128'h31415926535897932384626433832795;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		//key1
		tb_round_number = 4'd1;
		tb_key = 128'h02884197169399375105820974944592;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		//key2
		tb_round_number = 4'd2;
		tb_key = 128'h122f16b44177812762f3e3435170c4d6;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		//key3
		tb_round_number = 4'd3;
		tb_key = 128'hd3d95d61c54ac456944f465fe0db03cd;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		//key4
		tb_round_number = 4'd4;
		tb_key = 128'ha954ab55e8232a728ad0c931dba00de7;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		//key5
		tb_round_number = 4'd5;
		tb_key = 128'h6a398af5af734ea33b3c08fcdbe70b31;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		//key6
		tb_round_number = 4'd6;
		tb_key = 128'h397f6cecd15c469e5b8c8faf802c8248;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		//key7
		tb_round_number = 4'd7;
		tb_key = 128'ha74899a7083bd7043307dff8e8e0d4c9;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		//key8
		tb_round_number = 4'd8;
		tb_key = 128'hd037b177016bf7e95ae77846dacbfa0e;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		//key9
		tb_round_number = 4'd9;
		tb_key = 128'hf057b40cf86c6308cb6bbcf0238b6839;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		//key10
		tb_round_number = 4'd10;
		tb_key = 128'hfd72a351fc1954b8a6fe2cfe7c35d6f0;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		//key11
		tb_round_number = 4'd11;
		tb_key = 128'he0c1428018ad2188d3c69d78f04df541;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		//key12
		tb_round_number = 4'd12;
		tb_key = 128'h3e9420ddc28d74656473589b18468e6b;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		//key13
		tb_round_number = 4'd13;
		tb_key = 128'h4d9b5bff55367a7786f0e70f76bd124e;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		//key14
		tb_round_number = 4'd14;
		tb_key = 128'h045d0fe5c6d07b80a2a3231bbae5ad70;
		tb_load = 1'b1;
		#(CLK_PERIOD);
		tb_load = 1'b0;
	
	
		//LOAD DATA

		tb_encrypt_flag = 1'b1;
		tb_data_in = 128'h000102030405060708090a0b0c0d0e0f;
		tb_is_valid = 1'b1;
		#(CLK_PERIOD);
		tb_data_in = 128'h011102030405060708090a0b0c0d0fff;
		#(CLK_PERIOD);
		tb_data_in = 128'hffffffffffffffffffffffffffffffff;
		#(CLK_PERIOD);
		tb_data_in = 128'h00000000000000000000000000000000;
		#(CLK_PERIOD);
		//check to make sure busy
		expected_data_out = 128'h00000000000000000000000000000000;
		expected_busy_out = 1'b1;
		expected_ready_out = 1'b0;
		check_output();
		#(CLK_PERIOD);
		testcase = 2;
		expected_data_out = 128'h997a616dad216ab0320db5c848e02996;
		expected_busy_out = 1'b1;
		expected_ready_out = 1;
		#(CLK_PERIOD * 12);//takes 17 cycles after data is valid for ready
		check_output();
		expected_busy_out = 1'b0;
		expected_data_out = 128'h4c7d63a2920d02d8a74bbf5e969f86b3;
		testcase = 3;
		#(CLK_PERIOD)
		
		check_output();
		tb_is_valid = 1'b0;
		expected_data_out = 128'ha78551f782426a7b6bd84a07b552aa2f;
		testcase = 4;
		#(CLK_PERIOD)
		
		check_output();
		

		#(CLK_PERIOD)
		testcase = 5;
		expected_data_out = 128'hcd176a3ec1f7f4005d631f947c2e0a84;
		expected_busy_out = 1'b0;
		expected_ready_out = 1'b1;
		#(CLK_PERIOD*14)
		check_output();
		#(CLK_PERIOD*2)
		
		//DECRYPT
		testcase = 6;
		tb_encrypt_flag = 1'b0;
		tb_data_in = 128'h997a616dad216ab0320db5c848e02996;
		tb_is_valid = 1'b1;
		#(CLK_PERIOD);
		tb_data_in = 128'h4c7d63a2920d02d8a74bbf5e969f86b3;
		#(CLK_PERIOD);
		tb_data_in = 128'ha78551f782426a7b6bd84a07b552aa2f;
		#(CLK_PERIOD);
		tb_data_in = 128'hcd176a3ec1f7f4005d631f947c2e0a84;
		#(CLK_PERIOD);
		//check to make sure busy
		expected_data_out = 128'h00000000000000000000000000000000;
		expected_busy_out = 1'b1;
		expected_ready_out = 1'b0;
		check_output();
		#(CLK_PERIOD);
		testcase = 7;
		expected_data_out = 128'h000102030405060708090a0b0c0d0e0f;
		expected_busy_out = 1'b1;
		expected_ready_out = 1;
		#(CLK_PERIOD * 12);//takes 17 cycles after data is valid for ready
		check_output();
		expected_busy_out = 1'b0;
		expected_data_out = 128'h011102030405060708090a0b0c0d0fff;
		testcase = 8;
		#(CLK_PERIOD)
		
		check_output();
		tb_is_valid = 1'b0;
		expected_data_out = 128'hffffffffffffffffffffffffffffffff;
		testcase = 9;
		#(CLK_PERIOD)
		
		check_output();
		

		#(CLK_PERIOD)
		testcase = 10;
		expected_data_out = 128'h00000000000000000000000000000000;
		expected_busy_out = 1'b0;
		expected_ready_out = 1'b1;
		#(CLK_PERIOD*14)
		check_output();
		#(CLK_PERIOD*2)
		
	
		$stop;
	end

endmodule
