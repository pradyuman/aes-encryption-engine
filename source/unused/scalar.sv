// $Id: $
// File name:   scalar.sv
// Created:     11/28/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: AES module scalar. Can attach more aes modules with only one parameter


module data_route
#(
	paremeter NUM_AES = 3
)
(
	input wire clk,n_rst, d_tk, [127:0] tk_in, [NUM_AES-1:0] rdy, [128*NUM_AES-1:0] ecb_out,
	output wire busy,[NUM_AES-1:0] is_valid, [128*NUM_AES-1:0] ecb_in, [127:0] data_out,
);
	wire [NUM_AES,0] inpt;
	wire [NUM_AES-1,0] outpt;
	wire innxt,outnxt;
	wire poszero;
	
	assign busy=inpt[NUM_AES];

	edge_detect 	SWITCH		(.clk(clk),.n_rst(n_rst),.d_tk(d_tk),.d_edge(poszero));
	flex_stp_ring #(NUM_AES+1) 	RDY_POINTER (.clk(clk),.n_rst(n_rst),.shift_enable(in_nxt),.parallel_out(inpt));
	flex_stp_ring #(NUM_AES)	NXT_DATAORI (.clk(clk),.n_rst(n_rst),.shift_enable(out_nxt),.parallel_out(outpt));

	always_comb
	begin:inmux
		
	end


module flex_stp_ring
#(
	parameter NUM_BITS = 4
)
(
	input wire clk, n_rst, shift_enable, clear,
	output reg [NUM_BITS-1:0] parallel_out
);






	

