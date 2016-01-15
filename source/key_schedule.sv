// $Id: $
// File name:   key_schedule.sv
// Created:     12/1/2015
// Author:      Jeffrey Heath
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: stores the key schedule to be used by the encryption blocks. key schedule is generated in the XEX module and is passed in 1 key at a time, wound number
module key_schedule(
	input wire [3:0] round_number,
	input wire clk,
	input wire load,
	input wire [127:0] key,
	input wire [3:0] count1,
	input wire [3:0] count2,
	input wire [3:0] count3,
	input wire encrypt_flag,
	output wire [127:0] round_key_out1,
	output wire [127:0] round_key_out2,
	output wire [127:0] round_key_out3 
);
	//DECLARE LOCAL VARIABLES	
	reg [127:0] round_key0;
	reg [127:0] round_key1;
	reg [127:0] round_key2;
	reg [127:0] round_key3;
	reg [127:0] round_key4;
	reg [127:0] round_key5;
	reg [127:0] round_key6;
	reg [127:0] round_key7;
	reg [127:0] round_key8;
	reg [127:0] round_key9;
	reg [127:0] round_key10;
	reg [127:0] round_key11;
	reg [127:0] round_key12;
	reg [127:0] round_key13;
	reg [127:0] round_key14;

	reg [127:0] round_key0_next;
	reg [127:0] round_key1_next;
	reg [127:0] round_key2_next;
	reg [127:0] round_key3_next;
	reg [127:0] round_key4_next;
	reg [127:0] round_key5_next;
	reg [127:0] round_key6_next;
	reg [127:0] round_key7_next;
	reg [127:0] round_key8_next;
	reg [127:0] round_key9_next;
	reg [127:0] round_key10_next;
	reg [127:0] round_key11_next;
	reg [127:0] round_key12_next;
	reg [127:0] round_key13_next;
	reg [127:0] round_key14_next;

	wire [3:0] new_count1;
	wire [3:0] new_count2;
	wire [3:0] new_count3;

	//OUTPUT LOGIC
	assign round_key_out1 = (new_count1 == 4'd0) ? round_key0 : (new_count1 == 4'd1) ? round_key1 : (new_count1 == 4'd2) ? round_key2 : (new_count1 == 4'd3) ? round_key3 : (new_count1 == 4'd4) ? round_key4 : (new_count1 == 4'd5) ? round_key5 : (new_count1 == 4'd6) ? round_key6 : (new_count1 == 4'd7) ? round_key7 : (new_count1 == 4'd8) ? round_key8 : (new_count1 == 4'd9) ? round_key9 : (new_count1 == 4'd10) ? round_key10 : (new_count1 == 4'd11) ? round_key11 : (new_count1 == 4'd12) ? round_key12 : (new_count1 == 4'd13) ? round_key13 : (new_count1 == 4'd14) ? round_key14 : round_key14;
	assign round_key_out2 = (new_count2 == 4'd0) ? round_key0 : (new_count2 == 4'd1) ? round_key1 : (new_count2 == 4'd2) ? round_key2 : (new_count2 == 4'd3) ? round_key3 : (new_count2 == 4'd4) ? round_key4 : (new_count2 == 4'd5) ? round_key5 : (new_count2 == 4'd6) ? round_key6 : (new_count2 == 4'd7) ? round_key7 : (new_count2 == 4'd8) ? round_key8 : (new_count2 == 4'd9) ? round_key9 : (new_count2 == 4'd10) ? round_key10 : (new_count2 == 4'd11) ? round_key11 : (new_count2 == 4'd12) ? round_key12 : (new_count2 == 4'd13) ? round_key13 : (new_count2 == 4'd14) ? round_key14 : round_key14;
	assign round_key_out3 = (new_count3 == 4'd0) ? round_key0 : (new_count3 == 4'd1) ? round_key1 : (new_count3 == 4'd2) ? round_key2 : (new_count3 == 4'd3) ? round_key3 : (new_count3 == 4'd4) ? round_key4 : (new_count3 == 4'd5) ? round_key5 : (new_count3 == 4'd6) ? round_key6 : (new_count3 == 4'd7) ? round_key7 : (new_count3 == 4'd8) ? round_key8 : (new_count3 == 4'd9) ? round_key9 : (new_count3 == 4'd10) ? round_key10 : (new_count3 == 4'd11) ? round_key11 : (new_count3 == 4'd12) ? round_key12 : (new_count3 == 4'd13) ? round_key13 : (new_count3 == 4'd14) ? round_key14 : round_key14;

	//CHECK IF ENCRYPT OR DECRYPT
	assign new_count1 = (!encrypt_flag) ? 4'd14 - count1 : count1;
	assign new_count2 = (!encrypt_flag) ? 4'd14 - count2 : count2;
	assign new_count3 = (!encrypt_flag) ? 4'd14 - count3 : count3;	
/*
	always_comb begin
		if(!encrypt_flag) begin new_count1 = 4'd14 - count1; end
		else begin new_count1 = count1; end
		if(!encrypt_flag) begin new_count2 = 4'd14 - count2; end
		else begin new_count2 = count2; end
		if(!encrypt_flag) begin new_count3 = 4'd14 - count3; end
		else begin new_count3 = count3; end

	end
*/
	//LOAD LOGIC
	always_comb begin
		if(load) begin
			
			case(round_number)
				4'd0: begin round_key0_next = key; round_key1_next = round_key1; round_key2_next = round_key2; round_key3_next = round_key3; round_key4_next = round_key4; round_key5_next = round_key5; round_key6_next = round_key6; round_key7_next = round_key7; round_key8_next = round_key8; round_key9_next = round_key9; round_key10_next = round_key10; round_key11_next = round_key11; round_key12_next = round_key12; round_key13_next = round_key13; round_key14_next = round_key14; end
				4'd1: begin round_key0_next = round_key0; round_key1_next = key; round_key2_next = round_key2; round_key3_next = round_key3; round_key4_next = round_key4; round_key5_next = round_key5; round_key6_next = round_key6; round_key7_next = round_key7; round_key8_next = round_key8; round_key9_next = round_key9; round_key10_next = round_key10; round_key11_next = round_key11; round_key12_next = round_key12; round_key13_next = round_key13; round_key14_next = round_key14; end
				4'd2: begin round_key0_next = round_key0; round_key1_next = round_key1; round_key2_next = key; round_key3_next = round_key3; round_key4_next = round_key4; round_key5_next = round_key5; round_key6_next = round_key6; round_key7_next = round_key7; round_key8_next = round_key8; round_key9_next = round_key9; round_key10_next = round_key10; round_key11_next = round_key11; round_key12_next = round_key12; round_key13_next = round_key13; round_key14_next = round_key14; end
				4'd3: begin round_key0_next = round_key0; round_key1_next = round_key1; round_key2_next = round_key2; round_key3_next = key; round_key4_next = round_key4; round_key5_next = round_key5; round_key6_next = round_key6; round_key7_next = round_key7; round_key8_next = round_key8; round_key9_next = round_key9; round_key10_next = round_key10; round_key11_next = round_key11; round_key12_next = round_key12; round_key13_next = round_key13; round_key14_next = round_key14; end
				4'd4: begin round_key0_next = round_key0; round_key1_next = round_key1; round_key2_next = round_key2; round_key3_next = round_key3; round_key4_next = key; round_key5_next = round_key5; round_key6_next = round_key6; round_key7_next = round_key7; round_key8_next = round_key8; round_key9_next = round_key9; round_key10_next = round_key10; round_key11_next = round_key11; round_key12_next = round_key12; round_key13_next = round_key13; round_key14_next = round_key14; end
				4'd5: begin round_key0_next = round_key0; round_key1_next = round_key1; round_key2_next = round_key2; round_key3_next = round_key3; round_key4_next = round_key4; round_key5_next = key; round_key6_next = round_key6; round_key7_next = round_key7; round_key8_next = round_key8; round_key9_next = round_key9; round_key10_next = round_key10; round_key11_next = round_key11; round_key12_next = round_key12; round_key13_next = round_key13; round_key14_next = round_key14; end
				4'd6: begin round_key0_next = round_key0; round_key1_next = round_key1; round_key2_next = round_key2; round_key3_next = round_key3; round_key4_next = round_key4; round_key5_next = round_key5; round_key6_next = key; round_key7_next = round_key7; round_key8_next = round_key8; round_key9_next = round_key9; round_key10_next = round_key10; round_key11_next = round_key11; round_key12_next = round_key12; round_key13_next = round_key13; round_key14_next = round_key14; end
				4'd7: begin round_key0_next = round_key0; round_key1_next = round_key1; round_key2_next = round_key2; round_key3_next = round_key3; round_key4_next = round_key4; round_key5_next = round_key5; round_key6_next = round_key6; round_key7_next = key; round_key8_next = round_key8; round_key9_next = round_key9; round_key10_next = round_key10; round_key11_next = round_key11; round_key12_next = round_key12; round_key13_next = round_key13; round_key14_next = round_key14; end
				4'd8: begin round_key0_next = round_key0; round_key1_next = round_key1; round_key2_next = round_key2; round_key3_next = round_key3; round_key4_next = round_key4; round_key5_next = round_key5; round_key6_next = round_key6; round_key7_next = round_key7; round_key8_next = key; round_key9_next = round_key9; round_key10_next = round_key10; round_key11_next = round_key11; round_key12_next = round_key12; round_key13_next = round_key13; round_key14_next = round_key14; end
				4'd9: begin round_key0_next = round_key0; round_key1_next = round_key1; round_key2_next = round_key2; round_key3_next = round_key3; round_key4_next = round_key4; round_key5_next = round_key5; round_key6_next = round_key6; round_key7_next = round_key7; round_key8_next = round_key8; round_key9_next = key; round_key10_next = round_key10; round_key11_next = round_key11; round_key12_next = round_key12; round_key13_next = round_key13; round_key14_next = round_key14; end
				4'd10: begin round_key0_next = round_key0; round_key1_next = round_key1; round_key2_next = round_key2; round_key3_next = round_key3; round_key4_next = round_key4; round_key5_next = round_key5; round_key6_next = round_key6; round_key7_next = round_key7; round_key8_next = round_key8; round_key9_next = round_key9; round_key10_next = key; round_key11_next = round_key11; round_key12_next = round_key12; round_key13_next = round_key13; round_key14_next = round_key14; end
				4'd11: begin round_key0_next = round_key0; round_key1_next = round_key1; round_key2_next = round_key2; round_key3_next = round_key3; round_key4_next = round_key4; round_key5_next = round_key5; round_key6_next = round_key6; round_key7_next = round_key7; round_key8_next = round_key8; round_key9_next = round_key9; round_key10_next = round_key10; round_key11_next = key; round_key12_next = round_key12; round_key13_next = round_key13; round_key14_next = round_key14; end
				4'd12: begin round_key0_next = round_key0; round_key1_next = round_key1; round_key2_next = round_key2; round_key3_next = round_key3; round_key4_next = round_key4; round_key5_next = round_key5; round_key6_next = round_key6; round_key7_next = round_key7; round_key8_next = round_key8; round_key9_next = round_key9; round_key10_next = round_key10; round_key11_next = round_key11; round_key12_next = key; round_key13_next = round_key13; round_key14_next = round_key14; end
				4'd13: begin round_key0_next = round_key0; round_key1_next = round_key1; round_key2_next = round_key2; round_key3_next = round_key3; round_key4_next = round_key4; round_key5_next = round_key5; round_key6_next = round_key6; round_key7_next = round_key7; round_key8_next = round_key8; round_key9_next = round_key9; round_key10_next = round_key10; round_key11_next = round_key11; round_key12_next = round_key12; round_key13_next = key; round_key14_next = round_key14; end
				4'd14: begin round_key0_next = round_key0; round_key1_next = round_key1; round_key2_next = round_key2; round_key3_next = round_key3; round_key4_next = round_key4; round_key5_next = round_key5; round_key6_next = round_key6; round_key7_next = round_key7; round_key8_next = round_key8; round_key9_next = round_key9; round_key10_next = round_key10; round_key11_next = round_key11; round_key12_next = round_key12; round_key13_next = round_key13; round_key14_next = key; end
				default: begin round_key0_next = '0; round_key1_next = '0; round_key2_next = '0; round_key3_next = '0; round_key4_next = '0; round_key5_next = '0; round_key6_next = '0; round_key7_next = '0; round_key8_next = '0; round_key9_next = '0; round_key10_next = '0; round_key11_next = '0; round_key12_next = '0; round_key13_next = '0; round_key14_next = '0; end
			endcase
		end
		else begin round_key0_next = round_key0; round_key1_next = round_key1; round_key2_next = round_key2; round_key3_next = round_key3; round_key4_next = round_key4; round_key5_next = round_key5; round_key6_next = round_key6; round_key7_next = round_key7; round_key8_next = round_key8; round_key9_next = round_key9; round_key10_next = round_key10; round_key11_next = round_key11; round_key12_next = round_key12; round_key13_next = round_key13; round_key14_next = round_key14; end
	end

	always_ff @(posedge clk) begin
		round_key0<= round_key0_next;
		round_key1<= round_key1_next;
		round_key2<= round_key2_next;
		round_key3<= round_key3_next;
		round_key4<= round_key4_next;
		round_key5<= round_key5_next;
		round_key6<= round_key6_next;
		round_key7<= round_key7_next;
		round_key8<= round_key8_next;
		round_key9<= round_key9_next;
		round_key10<= round_key10_next;
		round_key11<= round_key11_next;
		round_key12<= round_key12_next;
		round_key13<= round_key13_next;
		round_key14<= round_key14_next;
	end

endmodule
