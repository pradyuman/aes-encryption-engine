// $Id: $
// File name:   tb_xexaes256.sv
// Created:     11/29/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: transformed from tb_xex_engine.

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
	output bit [127:0] data);
begin
	integer i,dummy;
	byte hexbuf1,hexbuf0;
	automatic string str="ab";

	for (i=15;i>=0;i=i-1) 
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

module tb_xexaes256 ();

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

	tb_xexaes256_DUT xex_default(.tb_clk(tb_clk));
	
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


module tb_xexaes256_DUT (
	input wire tb_clk
);
	reg tb_n_rst;
/*
	reg [511:0] key;
	reg [127:0] sector;	
	reg [127:0] random;
000000000000000000000000000000ff
2776966649575999699370245777496226357174286053234590452818281827
9245947409820551379993169741880295278333646284239397585326594131
*/
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

	reg tb_in_rdy,tb_out_rdy,tb_busy;
	reg [1:0] tb_mode;
	reg [127:0] tb_sector,tb_data_in,tb_data_out;

	xexaes256 DUT (.key_in(tb_key_in),
		.clk(tb_clk),.n_rst(tb_n_rst),.in_rdy(tb_in_rdy),.mode(tb_mode),.sector(tb_sector),.data_in(tb_data_in),.out_rdy(tb_out_rdy),.busy(tb_busy),.data_out(tb_data_out));

	initial
	begin
		
		tb_new_key=0;
		tb_n_rst=1;
		tb_mode=0;
		tb_sector=0;
		tb_data_in=0;
		tb_in_rdy=0;
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

		outfp=$fopen("xexplain.txt","w");
		outfpc=$fopen("xexcipher.txt","w");

		fork
		begin //feed input data
			tb_in_rdy=1'b1;
			for (i=0;i<4096;i=i+256)
			begin
				assert(std::randomize(tb_data_in));
				write_file(outfp,tb_data_in);
				do
				begin
					@(posedge tb_clk);
				end
				while (tb_busy!=1'b0);


				assert(std::randomize(tb_data_in));
				write_file(outfp,tb_data_in);

				do
				begin
					@(posedge tb_clk);
				end
				while (tb_busy!=1'b0);

				write_line(outfp);
			end
			tb_in_rdy=1'b0;
		end
		begin //capture output data
			tb_mode=2'b10;
			for (j=0;j<4096;j=j+256)
			begin
				do
				begin
					@(posedge tb_clk);
				end
				while (tb_out_rdy!=1'b1);
				write_file(outfpc,tb_data_out);
				do
				begin
					@(posedge tb_clk);
				end
				while (tb_out_rdy!=1'b1);

				write_file(outfpc,tb_data_out);
				write_line(outfpc);
			end
			tb_mode=2'b00;
		end
		join

		$fclose(outfp);
		$fclose(outfpc);

		#(200ns);

	//running under dec
		outfpc=$fopen("xexcipher.txt","r");
		outfp=$fopen("xexcplain.txt","w");

		fork
		begin //feed input data
			tb_in_rdy=1'b1;
			for (i=0;i<4096;i=i+256)
			begin
				read_file(outfpc,tb_data_in);
				do
				begin
					@(posedge tb_clk);
				end
				while (tb_busy!=1'b0);


				read_file(outfpc,tb_data_in);

				do
				begin
					@(posedge tb_clk);
				end
				while (tb_busy!=1'b0);

				read_line(outfpc);
			end
			tb_in_rdy=1'b0;
		end
		begin //capture output data
			tb_mode=2'b11;
			for (j=0;j<4096;j=j+256)
			begin
				do
				begin
					@(posedge tb_clk);
				end
				while (tb_out_rdy!=1'b1);

				write_file(outfp,tb_data_out);

				do
				begin
					@(posedge tb_clk);
				end
				while (tb_out_rdy!=1'b1);

				write_file(outfp,tb_data_out);
				write_line(outfp);
			end
			tb_mode=2'b00;
		end
		join

		$fclose(outfp);
		$fclose(outfpc);

	//generate reference files. xexplain is the original input.
	//check xexcipher against xexciphercheck to make sure encryption is working.
	//check xexcplain against xeccplaincheck to make sure decryption is working.
	//check xexplain against xexciphercheckcplain.txt to make sure the c file is working.
		xex_encrypt_file("xexkey.txt","xexplain.txt","xexciphercheck.txt");
		xex_decrypt_file("xexkey.txt","xexcipher.txt","xexcplaincheck.txt"); 
		xex_decrypt_file("xexkey.txt","xexciphercheck.txt","xexciphercheckcplain.txt"); 
		#(200ns);
		$finish;
	end
		

endmodule


