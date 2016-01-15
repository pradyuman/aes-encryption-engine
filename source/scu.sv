// File name:   scu.sv
// Author:      Pradyuman Vig
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: RCU for Lab 6
`timescale 1ns/10ps
module scu (
  input wire clk,
  input wire n_rst,
  input wire [1:0] scu_mode, //00 IDLE 10 ENCRYPT 11 DECRYPT
  input wire setup, //need information on this
  input wire row, //need more info
  input wire col, //need more info
  input wire [32767:0] data, //4096 bytes
  input wire c_exe,
  input wire c_in_busy,
  input wire n_run,
  input wire n_busy,
  input wire aes_busy,
  output reg c_busy,
  output reg c_run,
  output reg n_setup, //need more information
  output reg n_exe,
  output reg n_out_busy,
  output reg [1:0] aes_mode, //00 IDLE 10 ENCRYPT 11 DECRYPT
  output reg aes_tweak, //still need information on this
  output reg data_valid,
  output reg [127:0] aes_data,
  output reg error
);

typedef enum bit [4:0]
{
  IDLE, EIDLE,
  W_SETUP, W_CPU_WAIT, W_START, W_ENCRYPT, W_VALID, W_AES_WAIT, W_COUNTER,
  W_VERIFY, W_STORE, W_NAND_WAIT, W_NAND_DONE, W_DONE,
  R_SETUP, R_CPU_WAIT, R_START, R_NAND_WAIT, R_SET, R_DECRYPT, R_VALID,
  R_AES_WAIT, R_COUNTER, R_VERIFY, R_AES_DONE, R_DONE
} stateType;

stateType state;
stateType next_state;

reg clear, aes_cycle, aes_done;
reg [8:0] progress;

flex_counter
#(
  .NUM_CNT_BITS(9)
)
SCU_COUNTER
(
  .clk(clk),
  .n_rst(n_rst),
  .clear(clear),
  .count_enable(aes_cycle),
  .rollover_val(9'd256),
  .count_out(progress),
  .rollover_flag(aes_done)
);

always_ff @ (negedge n_rst, posedge clk)
begin: REG_LOGIC
   if (1'b0 == n_rst) begin
      state <= IDLE;
   end
   else begin
      state <= next_state;
   end
end

always_comb
begin: STATE_LOGIC
   case(state)
      IDLE: next_state = (scu_mode == 2'b10) ? W_SETUP : (scu_mode == 2'b11) ? R_SETUP : IDLE;
      EIDLE: next_state = IDLE;

      //ENCRYPTION
      W_SETUP: next_state = W_CPU_WAIT; //Passthrough CPU commands
      W_CPU_WAIT: next_state = c_exe ? W_START : W_CPU_WAIT; //Wait for CPU to start
      W_START: next_state = W_ENCRYPT; //Prepare SOC for encryption
      W_ENCRYPT: next_state = W_VALID; //Take next 128 bits
      W_VALID: next_state = W_AES_WAIT; //Assert data_valid one clock cycle
      W_AES_WAIT: next_state = aes_busy ? W_AES_WAIT : W_COUNTER; //Wait for AES module to finish
      W_COUNTER: next_state = aes_done ? W_STORE : W_ENCRYPT;
      //W_COUNTER: next_state = W_VERIFY; //Wait for next count to register
      //W_VERIFY: next_state = aes_done ? W_STORE : W_ENCRYPT; //Check if all data has been encrypted
      W_STORE: next_state = W_NAND_WAIT; //Write data and EXE to NAND | need another state if there is a delay in storing data
      W_NAND_WAIT: next_state = n_run ? W_NAND_WAIT : W_NAND_DONE; //Wait for data to store in NAND
      W_NAND_DONE: next_state = c_in_busy ? W_DONE : W_NAND_DONE; //Wait for CPU to clear the BSY bit
      W_DONE: next_state = IDLE; //ENCRYPTION COMPLETE

      //DECRYPTION
      R_SETUP: next_state = R_CPU_WAIT; //Passthrough CPU commands
      R_CPU_WAIT: next_state = c_exe ? R_START : R_CPU_WAIT; //Wait for CPU to start
      R_START: next_state = R_NAND_WAIT; //Emulate NAND for CPU
      R_NAND_WAIT: next_state = n_run ? R_NAND_WAIT : R_SET; //Wait for NAND to pull data
      R_SET: next_state = R_DECRYPT; //Setup AES module for decryption
      R_DECRYPT: next_state = R_VALID; //Take next 128 bits
      R_VALID: next_state = R_AES_WAIT; //Assert data_valid one clock cycle
      R_AES_WAIT: next_state = aes_busy ? R_AES_WAIT : R_COUNTER; //Wait for AES module to finish
      R_COUNTER: next_state = aes_done ? R_AES_DONE : R_DECRYPT;
      //R_COUNTER: next_state = R_VERIFY; //Wait for next count to register
      //R_VERIFY: next_state = aes_done ? R_AES_DONE : R_DECRYPT; //Check if all data has been decrypted
      R_AES_DONE: next_state = c_in_busy ? R_DONE : R_AES_DONE; //Wait for CPU to clear the BSY bit
      R_DONE: next_state = IDLE; //DECRYPTION COMPLETE

      default: next_state = EIDLE;
   endcase
end

//R_AES_DONE, R_NAND_DONE if interrupt
integer i;
always_comb
begin: OUTPUT_LOGIC
   case(next_state)
      IDLE: begin c_busy = 0; c_run = 0;
                  n_setup = 0; n_exe = 0; n_out_busy = 0;
                  aes_mode = 2'b00; aes_data = 0;
                  data_valid = 0; aes_cycle = 0;
                  clear = 1; error = 0; end
      EIDLE: error = 1;

      //ENCRYPTION
      W_SETUP: n_setup = setup;
      W_START: begin c_busy = 1; c_run = 1; aes_mode = 2'b10; end
      W_ENCRYPT: begin
                 aes_cycle = 0;
                 for(i=0; i<128; i++) begin
                    aes_data[i] = data[progress * 128 + i];
                 end
                 data_valid = 1; end
      W_VALID: data_valid = 0;
      W_COUNTER: aes_cycle = 1;
      W_STORE: begin aes_cycle = 0; n_exe = 1; end
      W_NAND_DONE: c_run = 0; //interrupt here
      W_DONE: n_out_busy = 1;

      //DECRYPTION
      R_SETUP: n_setup = setup;
      R_START: begin c_busy = 1; c_run = 1; n_exe = 1; end
      R_SET: aes_mode = 2'b11;
      R_DECRYPT: begin
                 aes_cycle = 0;
                 for(i=0; i<128; i++) begin
                    aes_data[i] = data[progress * 128 + i];
                 end
                 data_valid = 1; end
      R_VALID: data_valid = 0;
      R_COUNTER: aes_cycle = 1;
      R_AES_DONE: begin aes_cycle = 0; c_run = 0; end//interrupt here
      R_DONE: n_out_busy = 1;
      default: begin aes_cycle = 0; clear = 0; error = 0; end
   endcase
end

endmodule
