// $Id: $
// File name:   AES_engine.sv
// Created:     12/1/2015
// Author:      Jeffrey Heath
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: high level AES engine module. will communicate directly with XEX module
module AES_engine(
	input wire is_valid,
	input wire [127:0] data_in,
	input wire encrypt_flag,
	input wire clk,
	input wire n_rst,
	input wire [3:0] round_number,
	input wire load,
	input wire [127:0] key,
	output wire busy_out,
	output wire ready,
	output wire [127:0] data_out 
);

	//DECLARE LOCAL VARIABLES
	wire busy1;
	wire busy2;
	wire busy3;
	wire [127:0] data1;
	wire [127:0] data2;
	wire [127:0] data3;
	wire encrypt_flag1;
	wire encrypt_flag2;
	wire encrypt_flag3;
	wire enable1;
	wire enable2;
	wire enable3;

	wire [127:0] round_key1;
	wire [127:0] round_key2;
	wire [127:0] round_key3;
	wire [127:0] data_out1;
	wire [127:0] data_out2;
	wire [127:0] data_out3;
	wire [3:0] count1;
	wire [3:0] count2;
	wire [3:0] count3;
	wire ready1;
	wire ready2;
	wire ready3;
	
	
	

	//PORT MAPPING
	AES_controller control (.clk(clk), .data_in(data_in), .encrypt_flag(encrypt_flag), .is_valid(is_valid), .n_rst(n_rst), .busy1(busy1), .busy2(busy2), .busy3(busy3), .busy_out(busy_out), .data1(data1), .data2(data2), .data3(data3), .encrypt_flag1(encrypt_flag1), .encrypt_flag2(encrypt_flag2), .encrypt_flag3(encrypt_flag3), .enable1(enable1), .enable2(enable2), .enable3(enable3), .ready1(ready1), .ready2(ready2), .ready3(ready3));
	encrypt encrypt1 (.clk(clk), .n_rst(n_rst), .enable(enable1), .encryption_flag(encrypt_flag1), .data_in(data1), .round_key(round_key1), .data_out(data_out1), .count(count1), .busy(busy1), .ready(ready1));
	encrypt encrypt2 (.clk(clk), .n_rst(n_rst), .enable(enable2), .encryption_flag(encrypt_flag2), .data_in(data2), .round_key(round_key2), .data_out(data_out2), .count(count2), .busy(busy2), .ready(ready2));
	encrypt encrypt3 (.clk(clk), .n_rst(n_rst), .enable(enable3), .encryption_flag(encrypt_flag3), .data_in(data3), .round_key(round_key3), .data_out(data_out3), .count(count3), .busy(busy3), .ready(ready3));
	key_schedule schedule (.clk(clk), .round_number(round_number), .load(load), .key(key), .count1(count1), .count2(count2), .count3(count3), .round_key_out1(round_key1), .round_key_out2(round_key2), .round_key_out3(round_key3), .encrypt_flag(encrypt_flag1));
	
	//COMB LOGIC
	assign data_out = (ready1) ? data_out1 : (ready2) ? data_out2 : (ready3) ? data_out3 : 128'd0;
	assign ready = ready1 || ready2 || ready3; 
	
endmodule
