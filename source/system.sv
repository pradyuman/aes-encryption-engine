// $Id: $
// File name:   system.sv
// Created:     12/11/2015
// Author:      Pradyuman Vig
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: combined scu + xex aes block.


module system(
	input wire [511:0] key_in,
  input wire [127:0] sector,
  input wire clk,
  input wire n_rst,
  input wire [1:0] mode, //00 IDLE 10 ENCRYPT 11 DECRYPT
  input wire setup, //need information on this
  input wire [32767:0] data_in, //4096 bytes
  input wire c_exe,
  input wire c_in_busy,
  input wire n_run,
  input wire n_busy,
	output wire out_rdy,
  output wire [127:0] data_out,
  output reg c_busy,
  output reg c_run,
  output reg n_setup, //need more information
  output reg n_exe,
  output reg n_out_busy,
  output reg error
);
  wire [1:0] aes_mode;
  wire data_valid;
  wire [127:0] aes_data;
  wire aes_busy;

  scu PRADYUMAN (
    .clk(clk),
    .n_rst(n_rst),
    .scu_mode(mode),
    .setup(setup),
    .row(),
    .col(),
    .data(data_in),
    .c_exe(c_exe),
    .c_in_busy(c_in_busy),
    .n_run(n_run),
    .n_busy(n_busy),
    .aes_busy(aes_busy),
    .c_busy(c_busy),
    .c_run(c_run),
    .n_setup(n_setup),
    .n_exe(n_exe),
    .n_out_busy(n_out_busy),
    .aes_mode(aes_mode),
    .aes_tweak(),
    .data_valid(data_valid),
    .aes_data(aes_data),
    .error(error)
  );

  xexaes256 ALANJEFF (
    .key_in(key_in),
    .clk(clk),
    .n_rst(n_rst),
    .in_rdy(data_valid),
    .mode(aes_mode),
    .sector(sector),
    .data_in(aes_data),
  	.out_rdy(out_rdy),
    .busy(aes_busy),
    .data_out(data_out)
  );
endmodule
