// $Id: $
// File name:   evolve_key.sv
// Created:     11/16/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: evolving key rounds

module evolve_key
(
	input wire clk,n_rst,d_tk,[255:0] key1,key2,
	output reg ks_load,[2:0] ks_round, 
	output reg [255:0] ks_out
);
	wire load_new;
	wire count_done;
	reg [255:0] n_ks_out;
	reg [255:0] evolve_lib;
	wire [7:0] rconst;
	assign rconst=2**ks_round;

	edge_detect SWITCH	(.clk(clk),.n_rst(n_rst),.d_tk(d_tk),.d_edge(load_new));
	flex_counter #(3) ADDR	(.clk(clk),.n_rst(n_rst),.clear(load_new),.count_enable(ks_load),.rollover_val(3'b111),.count_out(ks_round),.rollover_flag(count_done));
	evolve_key_lib KSLIB	(.ks(ks_out),.rconst(rconst),.next_ks(evolve_lib));


	always_comb 
	begin: nextkey_out
		if (load_new==1'b1) 
		begin
			if (d_tk==1'b0) n_ks_out=key2;
			else n_ks_out=key1;
		end 
		else if (ks_load==1'b1) n_ks_out=evolve_lib;
		else n_ks_out=ks_out;
	end

	always_ff @ (posedge clk, negedge n_rst)
	begin : tiny_state_machine
		if (1'b0 == n_rst)
		begin
			ks_load<=0;
		end
		else
		begin
			if (load_new==1'b1) ks_load<=1'b1;
			else if (count_done==1'b1) ks_load<=1'b0;
			else ks_load<=ks_load;
		end
	end

	always_ff @ (posedge clk, negedge n_rst)
	begin : nextout
		if (1'b0 == n_rst)
		begin
			ks_out<=0;
		end
		else
		begin
			ks_out<=n_ks_out;
		end
	end



endmodule
