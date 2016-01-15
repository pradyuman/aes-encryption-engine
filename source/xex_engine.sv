// $Id: $
// File name:   xex_engine.sv
// Created:     11/28/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: top level module for the whole xex block.

//enc_dec 0->enc, 1->dec
//mode    00->idle, 10->enc, 11->dec

module xex_engine(
	//to key_manager
	input wire [511:0] key_in,
	//to ahb controller
	input wire clk, n_rst, in_rdy, [1:0] mode, [127:0] sector, data_in, 
	output wire out_rdy, busy, [127:0] data_out,
	//to aes engine, aes engine needs to take clock and reset signals from the top top level
	input wire aes_ready,aes_busy,[127:0] aes_out,
	output wire enc_dec,is_valid,ks_load,[3:0] ks_round,[127:0]aes_in,ks
);

	wire d_tk, tk_ud, read, write, d_valid, xex_bz;
	wire [127:0] oldalpha, alpha, a_out;
	
	assign busy=xex_bz;
	assign is_valid=d_valid;
	assign read=(d_valid)&&(!xex_bz);

	assign out_rdy=write;

	xex_controller BRAIN (
		.clk(clk),
		.n_rst(n_rst),
		.aes_rdy(aes_ready),
		.aes_bz(aes_busy),
		.in_rdy(in_rdy),
		.mode(mode),
		.d_valid(d_valid),
		.enc_dec(enc_dec),
		.d_tk(d_tk),
		.tk_ud(tk_ud),
		.xex_bz(xex_bz),
		.out_rdy(write)
	);
	
	evolve_key KEYSCH (
		.clk(clk),
		.n_rst(n_rst),
		.d_tk(d_tk),
		.key1(key_in[511:256]),
		.key2(key_in[255:0]),
		.ks_load(ks_load),
		.ks_round(ks_round),
		.ks_out(ks)
	);

	data_route ROUTER (
		.d_tk(d_tk),
		.tk_in(sector),
		.a_out(a_out),
		.aes_in(aes_in)
	);
	
	tweak TWEAKER (
		.clk(clk),
		.read(read),
		.write(write),
		.tk_ud(tk_ud),
		.tweak_0(aes_out),
		.alpha(alpha),
		.oldalpha(oldalpha)
	);

	add_alpha BIGXOR(
		.alpha(alpha),
		.oldalpha(oldalpha),
		.aes_out(aes_out),
		.data_in(data_in),
		.data_out(data_out),
		.aes_in(a_out)
	);

endmodule

