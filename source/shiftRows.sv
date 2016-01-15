// $Id: $
// File name:   shiftRows.sv
// Created:     11/22/2015
// Author:      Jeffrey Heath
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: shiftRows permutation
module shiftRows(
	input wire [127:0] data_in,
	output wire [127:0] data_out
);
/*
	assign data_out[7:0] = data_in[39:32]; //15
	assign data_out[15:8] = data_in[79:72];//14
	assign data_out[23:16] = data_in[119:112]; //13
	assign data_out[31:24] = data_in[31:24];//12
	assign data_out[39:32] = data_in[71:64];//11
	assign data_out[47:40] = data_in[111:104];//10
	assign data_out[55:48] = data_in[23:16]; //9
	assign data_out[63:56] = data_in[63:56];//8
	assign data_out[71:64] = data_in[103:96]; //7
	assign data_out[79:72] = data_in[15:8];//6
	assign data_out[87:80] = data_in[55:48]; //5
	assign data_out[95:88] = data_in[95:88];//4
	assign data_out[103:96] = data_in[7:0]; //3
	assign data_out[111:104] = data_in[47:40];//2
	assign data_out[119:112] = data_in[87:80]; //1
	assign data_out[127:120] = data_in[127:120];//0
*/
/*
	assign data_out[7:0] = data_in[7:0]; //0
	assign data_out[15:8] = data_in[47:40];//1
	assign data_out[23:16] = data_in[87:80]; //2
	assign data_out[31:24] = data_in[127:120];//3
	assign data_out[39:32] = data_in[39:32];//4
	assign data_out[47:40] = data_in[79:72];//5
	assign data_out[55:48] = data_in[119:112]; //6
	assign data_out[63:56] = data_in[31:24];//7
	assign data_out[71:64] = data_in[71:64]; //8
	assign data_out[79:72] = data_in[111:104];//9
	assign data_out[87:80] = data_in[23:16]; //10
	assign data_out[95:88] = data_in[63:56];//11
	assign data_out[103:96] = data_in[103:96]; //12
	assign data_out[111:104] = data_in[15:8];//13
	assign data_out[119:112] = data_in[55:48]; //14
	assign data_out[127:120] = data_in[95:88];//15
*/
assign data_out = {
	data_in[127:120],data_in[87:80],data_in[47:40],data_in[7:0],
	data_in[95:88],data_in[55:48],data_in[15:8],data_in[103:96],
	data_in[63:56],data_in[23:16],data_in[111:104],data_in[71:64],
	data_in[31:24],data_in[119:112],data_in[79:72],data_in[39:32] };
	
endmodule
