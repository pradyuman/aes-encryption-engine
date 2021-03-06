// $Id: $
// File name:   xexaes256.sv
// Created:     12/2/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: combined xex aes block.


module xexaes256(
	input wire [511:0] key_in,
	input wire clk, n_rst, in_rdy, [1:0] mode, [127:0] sector, data_in, 
	output wire out_rdy, busy, [127:0] data_out
);
	wire aes_ready,aes_busy;
	wire [127:0] aes_out;
	wire enc_dec,is_valid,ks_load;
	wire [3:0] ks_round;
	wire [127:0]aes_in,ks;

	AES_engine JEFF (
		.is_valid(is_valid),
		.data_in(aes_in),
		.encrypt_flag(!enc_dec),
		.clk(clk),
		.n_rst(n_rst),
		.round_number(ks_round),
		.load(ks_load),
		.key(ks),
		.busy_out(aes_busy),
		.ready(aes_ready),
		.data_out(aes_out)
	);

	xex_engine ALAN (
		.*		
		/*.key_in,
		.clk,
		.n_rst,
		.in_rdy(in_rdy),
		.mode(mode),
		.sector(sector),
		.data_in(data_in),
		.out_rdy(out_rdy),
		.busy(busy),
		.data_out(data_out),
		.aes_ready(aes_ready),
		.aes_busy(aes_busy),
		.aes_out(aes_out),
		.enc_dec(enc_dec),
		.is_valid(is_valid),
		.ks_load(ks_load),
		.ks_round(ks_round),
		.aes_in(aes_in),
		.ks*/
	);
endmodule

