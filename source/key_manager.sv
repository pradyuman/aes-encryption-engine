// $Id: $
// File name:   key_manager.sv
// Created:     11/24/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: pseudo hardware key manager

module key_manager
#(
	parameter K1 = 0,
	parameter K2 = 0
)
(
	output wire [511:0] key_in
);
	wire [255:0] key1,key2;
	assign key1=K1;
	assign key2=K2;
	assign key_in={key1,key2};

endmodule
