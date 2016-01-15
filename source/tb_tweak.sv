// $Id: $
// File name:   tb_tweak.sv
// Created:     11/16/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: testbench for tweak module. especially testing double in GF

`timescale 1ns / 10ps


module tb_tweak ();

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
	
	tb_tweak_DUT tweak_default(.tb_clk);
	
endmodule 


module tb_tweak_DUT (
	input wire tb_clk
);
	integer tb_test_case = 0;
	reg [127:0] tb_expected_alpha = 0;
	wire [127:0] tb_alpha,tb_oldalpha;
	reg tb_n_rst;
	reg tb_read,tb_write;
	reg tb_tk_ud;	
	reg [127:0] tb_tweak_0;

	tweak DUT (.clk(tb_clk),.n_rst(tb_n_rst),.read(tb_read),.tk_ud(tb_tk_ud),.tweak_0(tb_tweak_0),.alpha(tb_alpha),.oldalpha(tb_oldalpha),.write(tb_write));//connect to DUT
/*

555555555555555555555555555555d3
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaba6
555555555555555555555555555557cb
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaf96
55555555555555555555555555555fab
aaaaaaaaaaaaaaaaaaaaaaaaaaaabf56
55555555555555555555555555557e2b
aaaaaaaaaaaaaaaaaaaaaaaaaaaafc56


*/



	initial
	begin
		tb_n_rst=1;
		tb_read=0;
		tb_write=0;
		tb_tk_ud=0;
		tb_tweak_0 = 128'h8fbf94fd3d7da41ea0fe79f4bc5981d5;
		#(1ns)
		//test 0 reset/eop clear test
		reset_dut;
		@(negedge tb_clk);
		tb_tk_ud = 1;
		@(negedge tb_clk);
		tb_tk_ud = 0;
		@(negedge tb_clk);
		@(negedge tb_clk);
		tb_read = 1;
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		tb_read = 0;
		//if (tb_alpha!=tb_expected_alpha) $error("Incorrect alpha value for test case %d!", tb_test_case); 

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