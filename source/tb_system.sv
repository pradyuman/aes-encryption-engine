// $Id: $
// File name:   tb_system.sv
// Created:     12/11/2015
// Author:      Pradyuman Vig
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: transformed from tb_xexaes256.

/////if you're trying to use DPI with makefile provided, compile the c file using "vlog" first, and then copy work/_dpi to replace source_work|mapped_work/_dpi
/////or DPI won't work well.

import "DPI-C" function void aes256_ks_file(string inname,string outname);
import "DPI-C" function void aes256_encrypt_ecb_file(string keyname,string inname,string outname);
import "DPI-C" function void aes256_decrypt_ecb_file(string keyname,string inname,string outname);
import "DPI-C" function void xex_doubleingf_file(string inname,string outname);
import "DPI-C" function void xex_encrypt_file(string keyname,string inname,string outname);
import "DPI-C" function void xex_decrypt_file(string keyname,string inname,string outname);

`timescale 1ns / 10ps

task write_file(
	input integer outpt,
	input bit [127:0] data);
begin
	integer i;
	for (i=15;i>=0;i=i-1) $fwrite(outpt,"%02x",data[(8*i)+:8]);
end
endtask

task read_file(
	input integer inpt,
	output bit [32767:0] data);
begin
	integer i,dummy;
	byte hexbuf1,hexbuf0;
	automatic string str="ab";

	for (i=4095;i>=0;i=i-1)
	begin
		dummy=$fscanf(inpt,"%c",hexbuf1);
		dummy=$fscanf(inpt,"%c",hexbuf0);
		str.putc(0, hexbuf1);
		str.putc(1, hexbuf0);
		data[(8*i)+:8]=str.atohex();
	end
end
endtask

task read_line(input integer inpt);
begin
	integer dummy;
	byte hexbuf1,hexbuf0;
	dummy=$fscanf(inpt,"%c",hexbuf1);
	dummy=$fscanf(inpt,"%c",hexbuf0);
end
endtask


task write_line(input integer outpt);
begin
	$fwrite(outpt,"%c\n",13);
end
endtask

module tb_system ();

	localparam	CLK_PERIOD	= 5;
	reg tb_clk;

	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	tb_system_DUT system(.tb_clk(tb_clk));

endmodule

module soft_key_manager(
	input wire new_key,
	output reg [511:0] key_in='0
);

	always_comb
	begin
		if (new_key==1'b1) assert(std::randomize(key_in));
	end

endmodule


module tb_system_DUT (
	input wire tb_clk
);
	reg tb_n_rst;
/*
	//to key_manager
	input wire [511:0] key_in,
	//to ahb controller
	input wire clk, n_rst, in_rdy, [1:0] mode, [127:0] sector, data_in,
	output wire out_rdy, busy, [127:0] data_out,
	//to aes engine, aes engine needs to take clock and reset signals from the top top level
	input wire aes_ready,aes_busy,[127:0] aes_out,
	output wire enc_dec,is_valid,ks_load,[3:0] ks_round,[127:0]aes_in,ks
*/
	integer outfpc,outfp,outfpt,i,j;

	reg tb_new_key;
	reg [511:0] tb_key_in;
	soft_key_manager KM (.new_key(tb_new_key),.key_in(tb_key_in));

	reg tb_out_rdy;
	reg [1:0] tb_mode;
	reg [127:0] tb_sector,tb_data_out;
	reg [32767:0] tb_data_in;

	reg tb_setup, tb_c_exe, tb_c_in_busy, tb_n_run, tb_n_busy, tb_c_busy;
	reg tb_c_run, tb_n_setup, tb_n_exe, tb_n_out_busy, tb_error;

	system DUT (
		//Inputs
		.key_in(tb_key_in),
		.sector(tb_sector),
		.clk(tb_clk),
		.n_rst(tb_n_rst),
		.mode(tb_mode),
		.setup(tb_setup),
		.data_in(tb_data_in),
		.c_exe(tb_c_exe),
		.c_in_busy(tb_c_in_busy),
		.n_run(tb_n_run),
		.n_busy(tb_n_busy),
		//Outputs
		.out_rdy(tb_out_rdy),
		.data_out(tb_data_out),
		.c_busy(tb_c_busy),
		.c_run(tb_c_run),
		.n_setup(tb_n_setup),
		.n_exe(tb_n_exe),
		.n_out_busy(tb_n_out_busy),
		.error(tb_error)
		);

	initial
	begin

		tb_new_key=0;
		tb_n_rst=1;
		tb_mode=0;
		tb_sector=0;
		tb_data_in=0;

		tb_setup = 1;
		tb_c_exe = 0;
		tb_c_in_busy = 0;
		tb_n_run = 0;
		tb_n_busy = 0;
	//reset dut
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		tb_n_rst = 1'b0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(negedge tb_clk);
		tb_n_rst = 1;
		@(posedge tb_clk);

	//randomize new key, and sector
		@(negedge tb_clk);
		tb_new_key=1;
		@(negedge tb_clk);
		tb_new_key=0;
		$info("Key1: %x", tb_key_in[511:256]);
		$info("Key1: %x", tb_key_in[255:0]);
		assert(std::randomize(tb_sector));
		tb_sector[63:0]='0;
	//write key and sector
		outfp=$fopen("xexkey.txt","w");

		write_file(outfp,tb_key_in[511:384]);
		write_file(outfp,tb_key_in[383:256]);
		write_line(outfp);
		write_file(outfp,tb_key_in[255:128]);
		write_file(outfp,tb_key_in[127:0]);
		write_line(outfp);
		write_file(outfp,tb_sector);

		$fclose(outfp);
	//running under enc
		tb_mode = 2'b10;
		tb_c_exe = 1;
		assert(std::randomize(tb_data_in));
			tb_n_run = 1;
			tb_n_busy = 1;
			#(100ns)
			tb_n_run = 0;
			#(8000ns)
			tb_n_run = 0;
			tb_c_in_busy = 1;
			tb_mode=2'b00;

		#(200ns);
		tb_c_exe = 0;
		tb_c_in_busy = 0;
		tb_n_run = 0;
		tb_n_busy = 0;
	//running under dec
		tb_mode = 2'b11;
		#(100ns)
		tb_c_exe = 1;
		outfpc=$fopen("xexcipher.txt","r");
		outfp=$fopen("xexcplain.txt","w");
		read_file(outfpc,tb_data_in);
		begin //capture output data
	  	tb_n_run = 1;
		  tb_n_busy = 1;
	  	#(100ns)
	  	tb_n_run = 0;
			#(8000ns)
			tb_c_in_busy = 1;
			tb_mode=2'b00;
			#(200ns);
		end

		$fclose(outfp);
		$fclose(outfpc);

		$stop;
	end


endmodule
