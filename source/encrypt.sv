// $Id: $
// File name:   encrypt.sv
// Created:     11/30/2015
// Author:      Jeffrey Heath
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: encrpytion block module which will be implimented by AES engine block
module encrypt
(
	input wire clk,
	input wire n_rst,
	input wire enable,
	input wire encryption_flag,
	input wire [127:0] data_in,
	input wire [127:0] round_key,
	output reg [127:0] data_out,
	output wire [3:0] count,
	output wire busy,
	output wire ready
);

	//DECLARE LOCAL VARIABLES
	wire round14_flag;
	wire round0_flag;
	wire round1_flag;
	wire [127:0] shiftR_out;
	wire [127:0] invShiftR_out;
	wire [127:0] subB_out;
	wire [127:0] invSubB_out;
	wire [127:0] invSubB_in;

	//MIXCOLUMNS
	wire [127:0] mixC_out;
	wire [127:0] invMixC_out;
	wire [127:0] mixC_out2;
	wire [127:0] invMixC_out2;
	wire [127:0] mixC_out3;

	
	wire [127:0] addRoundK_out;
	wire [127:0] addRoundK_in;
	wire [127:0] addRoundK_in_d;

	//CREATE FUNCTIONAL BLOCKS
	shiftRows shiftRs (.data_in(data_out), .data_out(shiftR_out));
	invShiftRows invShiftRs (.data_in(invSubB_out), .data_out(invShiftR_out));
	subBytes subBs (.data_in(shiftR_out), .data_out(subB_out));
	invSubBytes invSubBs (.data_in(invSubB_in), .data_out(invSubB_out));
	mix_columns mixC (.in(subB_out), .out(mixC_out));
	inv_mix_columns invMixC (.in(data_out), .out(invMixC_out));
	addRoundKey addRoundK (.data_in(addRoundK_in), .data_out(addRoundK_out), .roundKey(round_key));
	//MAY NEED TO CHANGE THIS
	flex_counter counter (.clk(clk), .n_rst(n_rst), .clear(!enable), .count_enable(enable), .rollover_val(4'd15), .count_out(count), .rollover_flag());
	
	//LOGIC FOR ADDROUNDKEY INPUT
	assign mixC_out2 = round14_flag ? subB_out : mixC_out;
	assign invMixC_out2 = invShiftR_out;
	assign mixC_out3 = encryption_flag ? mixC_out2 : invMixC_out2;
	assign addRoundK_in = round0_flag ? data_in : mixC_out3;
	
	//DECRYPT LOGIC ROUND1
	assign invSubB_in = round1_flag ? data_out : invMixC_out;


	//LOGIC FOR ROUND COUNTER OUTPUT
	assign round0_flag = (count == 4'd0) ? 1'b1 : 1'b0;
	assign round14_flag = (count == 4'd14) ? 1'b1 : 1'b0;
	assign ready = (count == 4'd15) ? 1'b1 : 1'b0;
	assign round1_flag = (count == 4'd1) ? 1'b1 : 1'b0;
	assign busy = !round0_flag;

	//UPDATE DATA REG
	always_ff @ (posedge clk) begin
		data_out <= addRoundK_out;
	end

endmodule

