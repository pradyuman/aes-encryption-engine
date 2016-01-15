// $Id: $
// File name:   tb_evolve_key.sv
// Created:     11/24/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: test bench for evolve key module.
// 

`timescale 1ns / 10ps


module tb_evolve_key ();

	localparam	CLK_PERIOD	= 5; 

	// Shared Test Variables
	reg tb_clk;
	
	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end
	
	tb_evolve_key_DUT evolve_key_default(.tb_clk);
	
endmodule 


module tb_evolve_key_DUT (
	input wire tb_clk
);
	integer tb_test_case = 0;
	reg [255:0] tb_key1 = 256'h3141592653589793238462643383279502884197169399375105820974944592;
	reg [255:0] tb_key2 = 256'h2718281828459045235360287471352662497757247093699959574966967627;
	reg [127:0] tb_ks_out;
	reg tb_d_tk;
	reg tb_n_rst;
	reg tb_ks_load;
	reg [3:0] tb_ks_round;	
	
	evolve_key DUT (.clk(tb_clk),.n_rst(tb_n_rst),.d_tk(tb_d_tk),.key1(tb_key1),.key2(tb_key2),.ks_load(tb_ks_load),.ks_round(tb_ks_round),.ks_out(tb_ks_out));//connect to DUT

	initial
	begin
		tb_d_tk=1;
		tb_n_rst=1;
		#(1ns)
		reset_dut;

		@(negedge tb_clk);
		tb_d_tk=0;
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		tb_d_tk=1;
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
	end
	
	task reset_dut;
	begin
		// Activate the design's reset (does not need to be synchronize with clock)
		tb_n_rst = 1'b0;

		// Wait for a couple clock cycles
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		// Release the reset
		@(negedge tb_clk);
		tb_n_rst = 1;
		
		// Wait for a while before activating the design
		@(posedge tb_clk);
		@(posedge tb_clk);
	end
	endtask
	
endmodule
