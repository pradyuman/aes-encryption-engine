// $Id: $
// File name:   AES_controller.sv
// Created:     11/30/2015
// Author:      Jeffrey Heath
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: high level controller of the AES module. enables individual encrypt blocks and asserts busy signal when now encrypt block is available
module AES_controller(
	input wire is_valid,
	input wire [127:0] data_in,
	input wire encrypt_flag,
	input wire clk,
	input wire n_rst,
	input wire busy1,
	input wire busy2,
	input wire busy3,
	input wire ready1,
	input wire ready2,
	input wire ready3,
	output wire busy_out,

	//outputs to encrypt blocks
	output reg [127:0] data1,
	output reg [127:0] data2,
	output reg [127:0] data3,
	output reg encrypt_flag1,
	output reg encrypt_flag2,
	output reg encrypt_flag3,
	output reg enable1,
	output reg enable2,
	output reg enable3
);
	//DECLARE LOCAL VARIABLES
	reg [127:0] data1_next;
	reg [127:0] data2_next;
	reg [127:0] data3_next;
	reg encrypt_flag1_next;
	reg encrypt_flag2_next;
	reg encrypt_flag3_next;
	reg enable1_next;
	reg enable2_next;
	reg enable3_next;
	
	//BUSY_OUT LOGIC (high if all 3 busy_in signals are high)
	assign busy_out = (enable1 && enable2) ? ((enable3) ? 1'b1 : 1'b0) : 1'b0; 
	
	always_comb begin
		if(is_valid) begin
			if(!enable1) begin
				//ACTIVATE
				enable1_next = 1'b1;
				data1_next = data_in;
				encrypt_flag1_next = encrypt_flag;
				if(ready2) begin enable2_next = 1'b0; end
				else begin enable2_next = enable2; end
				data2_next = data2;
				encrypt_flag2_next = encrypt_flag2;

				if(ready3) begin
					enable3_next = 1'b0;
				end
				else begin 
					enable3_next = enable3;
				end
				data3_next = data3;
				encrypt_flag3_next = encrypt_flag3;
			end

			else if(!enable2) begin
				if (ready1) begin
					enable1_next = 1'b0;
				end
				else begin
					enable1_next = enable1;
				end
				data1_next = data1;
				encrypt_flag1_next = encrypt_flag1;
				//ACTIVATE
				enable2_next = 1'b1;
				data2_next = data_in;
				encrypt_flag2_next = encrypt_flag;

				if (ready3) begin enable3_next = 1'b0; end
				else begin enable3_next = enable3; end
				data3_next = data3;
				encrypt_flag3_next = encrypt_flag3;
			end

			else if(!enable3) begin
				if (ready1) begin enable1_next = 1'b0; end
				else begin enable1_next = enable1; end
				data1_next = data1;
				encrypt_flag1_next = encrypt_flag1;

				if (ready2) begin enable2_next = 1'b0; end
				else begin enable2_next = enable2; end
				data2_next = data2;
				encrypt_flag2_next = encrypt_flag2;
				//ACTIVATE
				enable3_next = 1'b1;
				data3_next = data_in;
				encrypt_flag3_next = encrypt_flag;
			end

			else begin
				if (ready1) begin enable1_next = 1'b0; end
				else begin enable1_next = enable1; end
				data1_next = data1;
				encrypt_flag1_next = encrypt_flag1;

				if (ready2) begin enable2_next = 1'b0; end
				else begin enable2_next = enable2; end
				data2_next = data2;
				encrypt_flag2_next = encrypt_flag2;

				if (ready3) begin enable3_next = 1'b0; end
				else begin enable3_next = enable3; end
				data3_next = data3;
				encrypt_flag3_next = encrypt_flag3;			
			end
		end
		else begin
			if (ready1) begin enable1_next = 1'b0; end
			else begin enable1_next = enable1; end
			data1_next = data1;
			encrypt_flag1_next = encrypt_flag1;
			if (ready2) begin enable2_next = 1'b0; end
			else begin enable2_next = enable2; end
			data2_next = data2;
			encrypt_flag2_next = encrypt_flag2;
			if (ready3) begin enable3_next = 1'b0; end
			else begin enable3_next = enable3; end
			data3_next = data3;
			encrypt_flag3_next = encrypt_flag3;
		end
	end

	//UPDATE FLIPFLOPS
	always_ff @(posedge clk, negedge n_rst) begin
		if(!n_rst) begin
			enable1 <= 1'b0;
			enable2 <= 1'b0;
			enable3 <= 1'b0;
			data1 <= '0;
			data2 <= '0;
			data3 <= '0;
			encrypt_flag1 <= 1'b1;
			encrypt_flag2 <= 1'b1;
			encrypt_flag3 <= 1'b1;
		end
		else begin
			enable1 <= enable1_next;
			enable2 <= enable2_next;
			enable3 <= enable3_next;
			data1 <= data1_next;
			data2 <= data2_next;
			data3 <= data3_next;
			encrypt_flag1 <= encrypt_flag1_next;
			encrypt_flag2 <= encrypt_flag2_next;
			encrypt_flag3 <= encrypt_flag3_next;
		end
	end
endmodule
