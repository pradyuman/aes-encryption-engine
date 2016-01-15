// $Id: $
// File name:   tb_xex_engine.sv
// Created:     11/29/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: top level test bench for xex_engine.

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

module tb_xex_engine ();

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

	tb_xex_engine_DUT xex_default(.tb_clk(tb_clk));
	
endmodule 

module soft_aes(
	input wire clk, n_rst, enc_dec,is_valid,ks_load,[3:0] ks_round,[127:0]aes_in,ks,
	output reg aes_ready,aes_busy,[127:0] aes_out
);

	integer i1,i2,i3,infp1,infp2,infp3,outfp,j1,j2,j3;
	reg [127:0] aes_in_buffer;
	reg in_next;
	reg [127:0] buffer [3:1];
	reg [2:0] block_avail;
	reg ready_flag [3:1]={0,0,0};
	reg busy_flag [3:1]={0,0,0};
	reg [127:0] block_out [3:1];
	reg [127:0] keyschedule [14:0];

	always_ff @ (posedge clk) 
	begin
		aes_in_buffer=aes_in;
	end

	always_ff @ (posedge clk, negedge n_rst)
	begin:soft_flex_stp_ring
		if (1'b0 == n_rst)
		begin
			block_avail<=1;
		end
		else
		begin
			if (in_next) block_avail<={block_avail[1:0],block_avail[2]};
			else block_avail<=block_avail;
		end
	end

	always_comb
	begin:busy_indicator
		if (busy_flag[1]==1'b1&&busy_flag[2]==1'b1&&busy_flag[3]==1'b1) aes_busy=1'b1;
		else aes_busy=1'b0;

		aes_ready=ready_flag[1]|ready_flag[2]|ready_flag[3];
	end
	
	assign in_next=is_valid&&!aes_busy;

	always_ff @ (posedge clk)
	begin:load_ks_round
		if (ks_load) 
		begin
			keyschedule[ks_round]<=ks;
		end 
		else keyschedule[ks_round]<=keyschedule[ks_round];
	end
	
	always_comb
	begin:output_mux
		if (ready_flag[1]==1'b1) aes_out=block_out[1];
		else if (ready_flag[2]==1'b1) aes_out=block_out[2];
		else if (ready_flag[3]==1'b1) aes_out=block_out[3];
		else aes_out='0;
	end

	always @ (posedge clk)
	begin:first_aes_block
		if (is_valid&&block_avail[0]) 
		begin
		#(1ns);
		if (enc_dec==1'b0) 
		begin
			busy_flag[1]=1'b1;
			outfp=$fopen("aesplain1.txt","w");
			write_file(outfp,aes_in_buffer);
			$fclose(outfp);
			aes256_encrypt_ecb_file("aeskey1.txt","aesplain1.txt","aescipher1.txt");
			infp1=$fopen("aescipher1.txt","r");
			read_file(infp1,buffer[1]);
			$fclose(infp1);
			infp1=$fopen("aesks.txt","r");
/*
			for (i1=0;i1<15;i1=i1+1)
			begin 
				read_file(infp1,buffer[1]);
				read_line(infp1);
				assert(keyschedule[i1]==buffer[1])
				else $error("key schedule doesn't match");
				#(5ns);
			end
*/
			#(74ns);
			$fclose(infp1);
			block_out[1]=buffer[1];
			ready_flag[1]=1'b1;
			#(5ns);
			ready_flag[1]=1'b0;
			busy_flag[1]=1'b0;
		end
		else
		begin
			busy_flag[1]=1'b1;
			outfp=$fopen("aescipher1.txt","w");
			write_file(outfp,aes_in_buffer);
			$fclose(outfp);
			aes256_decrypt_ecb_file("aeskey1.txt","aescipher1.txt","aesplain1.txt");
			infp1=$fopen("aesks.txt","r");
/*
			for (i1=0;i1<15;i1=i1+1)
			begin 
				read_file(infp1,buffer[1]);
				read_line(infp1);
				assert(keyschedule[i1]==buffer[1])
				else $error("key schedule doesn't match");
				#(5ns);
			end
*/
			#(74ns);
			$fclose(infp1);
			infp1=$fopen("aesplain1.txt","r");
			read_file(infp1,buffer[1]);
			$fclose(infp1);
			block_out[1]=buffer[1];
			ready_flag[1]=1'b1;
			#(5ns);
			ready_flag[1]=1'b0;
			busy_flag[1]=1'b0;
		end
		end
	end

	always @ (posedge clk)
	begin:second_aes_block
		if (is_valid&&block_avail[1]) 
		begin
		#(1ns);
		if (enc_dec==1'b0) 
		begin
			busy_flag[2]=1'b1;
			outfp=$fopen("aesplain2.txt","w");
			write_file(outfp,aes_in_buffer);
			$fclose(outfp);
			aes256_encrypt_ecb_file("aeskey2.txt","aesplain2.txt","aescipher2.txt");

			infp2=$fopen("aescipher2.txt","r");
			read_file(infp2,buffer[2]);
			$fclose(infp2);
			infp2=$fopen("aesks.txt","r");
/*
			for (i2=0;i2<15;i2=i2+1)
			begin 
				read_file(infp2,buffer[2]);
				read_line(infp2);
				assert(keyschedule[i2]==buffer[2])
				else $error("key schedule doesn't match");
				#(5ns);
			end
*/			#(74ns);

			$fclose(infp2);
			block_out[2]=buffer[2];
			ready_flag[2]=1'b1;
			#(5ns);
			ready_flag[2]=1'b0;
			busy_flag[2]=1'b0;
		end
		else
		begin
			busy_flag[2]=1'b1;
			outfp=$fopen("aescipher2.txt","w");
			write_file(outfp,aes_in_buffer);
			$fclose(outfp);
			aes256_decrypt_ecb_file("aeskey2.txt","aescipher2.txt","aesplain2.txt");
			infp2=$fopen("aesks.txt","r");
/*
			for (i2=0;i2<15;i2=i2+1)
			begin 
				read_file(infp2,buffer[2]);
				read_line(infp2);
				assert(keyschedule[i2]==buffer[2])
				else $error("key schedule doesn't match");
				#(5ns);
			end
*/			#(74ns);
			$fclose(infp2);
			infp2=$fopen("aesplain2.txt","r");
			read_file(infp2,buffer[2]);
			$fclose(infp2);
			block_out[2]=buffer[2];
			ready_flag[2]=1'b1;
			#(5ns);
			ready_flag[2]=1'b0;
			busy_flag[2]=1'b0;
		end
		end

	end

	always @ (posedge clk)
	begin:third_aes_block
		if (is_valid&&block_avail[2]) 
		begin
		#(1ns);
		if (enc_dec==1'b0) 
		begin
			busy_flag[3]=1'b1;
			outfp=$fopen("aesplain3.txt","w");
			write_file(outfp,aes_in_buffer);
			$fclose(outfp);
			aes256_encrypt_ecb_file("aeskey3.txt","aesplain3.txt","aescipher3.txt");
			infp3=$fopen("aescipher3.txt","r");
			read_file(infp3,buffer[3]);
			$fclose(infp3);

			infp3=$fopen("aesks.txt","r");
/*
			for (i3=0;i3<15;i3=i3+1)
			begin 
				read_file(infp3,buffer[3]);
				read_line(infp3);
				assert(keyschedule[i3]==buffer[3])
				else $error("key schedule doesn't match");
				#(5ns);
			end
*/			#(74ns);
			$fclose(infp3);

			block_out[3]=buffer[3];
			ready_flag[3]=1'b1;
			#(5ns);
			ready_flag[3]=1'b0;
			busy_flag[3]=1'b0;
		end
		else
		begin
			busy_flag[3]=1'b1;
			outfp=$fopen("aescipher3.txt","w");
			write_file(outfp,aes_in_buffer);
			$fclose(outfp);
			aes256_decrypt_ecb_file("aeskey3.txt","aescipher3.txt","aesplain3.txt");
			infp3=$fopen("aesks.txt","r");
/*
			for (i3=0;i3<15;i3=i3+1)
			begin 
				read_file(infp3,buffer[3]);
				read_line(infp3);
				assert(keyschedule[i3]==buffer[3])
				else $error("key schedule doesn't match");
				#(5ns);
			end
*/			#(74ns);
			$fclose(infp3);
			infp3=$fopen("aesplain3.txt","r");
			read_file(infp3,buffer[3]);
			$fclose(infp3);
			block_out[3]=buffer[3];
			ready_flag[3]=1'b1;
			#(5ns);
			ready_flag[3]=1'b0;
			busy_flag[3]=1'b0;
		end
		end

	end



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


module tb_xex_engine_DUT (
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

	reg tb_aes_ready,tb_aes_busy,tb_enc_dec,tb_is_valid,tb_ks_load;
	reg [127:0] tb_aes_out,tb_aes_in,tb_ks;
	reg [3:0] tb_ks_round;
	soft_aes AES (.clk(tb_clk),.n_rst(tb_n_rst),.enc_dec(tb_enc_dec),.is_valid(tb_is_valid),.ks_load(tb_ks_load),.ks_round(tb_ks_round),.aes_in(tb_aes_in),.ks(tb_ks),
		 .aes_ready(tb_aes_ready),.aes_busy(tb_aes_busy),.aes_out(tb_aes_out));

	reg tb_in_rdy,tb_out_rdy,tb_busy;
	reg [1:0] tb_mode;
	reg [127:0] tb_sector,tb_data_in,tb_data_out;

	xex_engine FAT_DUT (.key_in(tb_key_in),
		.clk(tb_clk),.n_rst(tb_n_rst),.in_rdy(tb_in_rdy),.mode(tb_mode),.sector(tb_sector),.data_in(tb_data_in),.out_rdy(tb_out_rdy),.busy(tb_busy),.data_out(tb_data_out),
		.aes_ready(tb_aes_ready),.aes_busy(tb_aes_busy),.aes_out(tb_aes_out),.enc_dec(tb_enc_dec),.is_valid(tb_is_valid),.ks_load(tb_ks_load),.ks_round(tb_ks_round),.aes_in(tb_aes_in),.ks(tb_ks));

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
	//write key and sector, and prepare key file for soft_aes
		outfp=$fopen("aeskey1.txt","w");
		write_file(outfp,tb_key_in[511:384]);
		write_file(outfp,tb_key_in[383:256]);
		$fclose(outfp);
		outfp=$fopen("aeskey2.txt","w");
		write_file(outfp,tb_key_in[511:384]);
		write_file(outfp,tb_key_in[383:256]);
		$fclose(outfp);
		outfp=$fopen("aeskey3.txt","w");
		write_file(outfp,tb_key_in[511:384]);
		write_file(outfp,tb_key_in[383:256]);
		$fclose(outfp);
		aes256_ks_file("aeskey1.txt","aesks.txt");

		outfp=$fopen("xexkey.txt","w");

		write_file(outfp,tb_key_in[511:384]);
		write_file(outfp,tb_key_in[383:256]);
		write_line(outfp);
		write_file(outfp,tb_key_in[255:128]);
		write_file(outfp,tb_key_in[127:0]);
		write_line(outfp);
		write_file(outfp,tb_sector);

		$fclose(outfp);
	//running the xex_engine under enc

		outfp=$fopen("xexplain.txt","w");
		outfpc=$fopen("xexcipher.txt","w");

		fork
		begin //feed input data
			tb_in_rdy=1'b1;
			for (i=0;i<4096;i=i+256)
			begin
				assert(std::randomize(tb_data_in));
				write_file(outfp,tb_data_in);
			//generate new key files for soft_ks
				if (i==0)
				begin
					@(posedge tb_ks_load);
					@(posedge tb_ks_load);
					outfpt=$fopen("aeskey1.txt","w");
					write_file(outfpt,tb_key_in[255:128]);
					write_file(outfpt,tb_key_in[127:0]);
					$fclose(outfpt);
					outfpt=$fopen("aeskey2.txt","w");
					write_file(outfpt,tb_key_in[255:128]);
					write_file(outfpt,tb_key_in[127:0]);
					$fclose(outfpt);
					outfpt=$fopen("aeskey3.txt","w");
					write_file(outfpt,tb_key_in[255:128]);
					write_file(outfpt,tb_key_in[127:0]);
					$fclose(outfpt);
					aes256_ks_file("aeskey1.txt","aesks.txt");
				end

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
		outfp=$fopen("aeskey1.txt","w");
		write_file(outfp,tb_key_in[511:384]);
		write_file(outfp,tb_key_in[383:256]);
		$fclose(outfp);
		outfp=$fopen("aeskey2.txt","w");
		write_file(outfp,tb_key_in[511:384]);
		write_file(outfp,tb_key_in[383:256]);
		$fclose(outfp);
		outfp=$fopen("aeskey3.txt","w");
		write_file(outfp,tb_key_in[511:384]);
		write_file(outfp,tb_key_in[383:256]);
		$fclose(outfp);
		aes256_ks_file("aeskey1.txt","aesks.txt");

	//running the xex_engine under dec
		outfpc=$fopen("xexcipher.txt","r");
		outfp=$fopen("xexcplain.txt","w");

		fork
		begin //feed input data
			tb_in_rdy=1'b1;
			for (i=0;i<4096;i=i+256)
			begin
				read_file(outfpc,tb_data_in);

			//generate new key files for soft_ks
				if (i==0)
				begin
					@(posedge tb_ks_load);
					@(posedge tb_ks_load);
					outfpt=$fopen("aeskey1.txt","w");
					write_file(outfpt,tb_key_in[255:128]);
					write_file(outfpt,tb_key_in[127:0]);
					$fclose(outfpt);
					outfpt=$fopen("aeskey2.txt","w");
					write_file(outfpt,tb_key_in[255:128]);
					write_file(outfpt,tb_key_in[127:0]);
					$fclose(outfpt);
					outfpt=$fopen("aeskey3.txt","w");
					write_file(outfpt,tb_key_in[255:128]);
					write_file(outfpt,tb_key_in[127:0]);
					$fclose(outfpt);
					aes256_ks_file("aeskey1.txt","aesks.txt");
				end

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

		xex_encrypt_file("xexkey.txt","xexplain.txt","xexciphercheck.txt");
		xex_decrypt_file("xexkey.txt","xexcipher.txt","xexcplaincheck.txt"); 
		xex_decrypt_file("xexkey.txt","xexciphercheck.txt","xexciphercheckcplain.txt"); 
		#(200ns);
		$finish;
	end
		

endmodule

/*
		outfp=$fopen("xexkey.txt","w");
		write_file(outfp,128'h95278333646284239397585326594131);
		write_file(outfp,128'h92459474098205513799931697418802);
		write_line(outfp);
		write_file(outfp,128'h26357174286053234590452818281827);
		write_file(outfp,128'h27769666495759996993702457774962);
		write_line(outfp);
		write_file(outfp,128'h000000000000000000000000000000ff);
		$fclose(outfp);
		xex_encrypt_file("xexkey.txt","xexplain.txt","xexcipher.txt"); 
		$finish;
*/
