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
	output reg ks_load,[3:0] ks_round, 
	output reg [127:0] ks_out
);
	
	wire load_new;
	wire count_done;
	reg [255:0] ks_full,n_ks_out,evolve_lib;
	wire [255:0] evolve_lib0,evolve_lib1;
	wire [7:0] rconst;

	assign ks_out=ks_full[255:128];

	edge_detect 	SWITCH		(.clk(clk),.n_rst(n_rst),.d_tk(d_tk),.d_edge(load_new));
	flex_counter 	#(4) ADDR	(.clk(clk),.n_rst(n_rst),.clear(load_new),.count_enable(ks_load),.rollover_val(4'b1110),.count_out(ks_round),.rollover_flag(count_done));
	evolve_key_256 	#(0) KSLIB0	(.key_in(ks_full),.rconst(rconst),.key_out(evolve_lib0));
	evolve_key_256 	#(1) KSLIB1	(.key_in(ks_full),.rconst(rconst),.key_out(evolve_lib1));
	flex_stp_ring 	#(8) RCONST	(.clk(clk),.n_rst(n_rst),.shift_enable(ks_round[0]),.clear(load_new),.parallel_out(rconst));

	always_comb 
	begin: lib_sel
		if (ks_round[0]==1'b0) evolve_lib=evolve_lib0;
		else evolve_lib=evolve_lib1;
	end

	always_comb 
	begin: nextkey_out
		if (load_new==1'b1) 
		begin
			if (d_tk==1'b0) n_ks_out=key1;
			else n_ks_out=key2;
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
			ks_full<=0;
		end
		else
		begin
			ks_full<=n_ks_out;
		end
	end

endmodule
