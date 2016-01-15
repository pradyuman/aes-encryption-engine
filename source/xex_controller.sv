// $Id: $
// File name:   controller.sv
// Created:     11/28/2015
// Author:      Xiangyu Li
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: controller block of the whole xex module.


// mode 00 idle, mode 10 enc, mode 11 dec

module xex_controller(	
	input wire clk,n_rst,aes_rdy,aes_bz,in_rdy,[1:0] mode,
	output reg d_valid,enc_dec,d_tk,tk_ud,xex_bz,out_rdy 
);

	typedef enum logic [4:0] {idle,wkstk1,wkstk2,wkstk3,sdtk,enctk,wksd1,wksd2,wksd3,data,//sddata,
				wksdec1,wksdec2,wksdec3,wksdec4,wksdec5,wksdec6,wksdec7,wksdec8,wksdec9,wksdec10,wksdec11,wksdec12,wksdec13,wksdec14}
	state_type;
	state_type state, nextstate;

	always_comb
	begin : nextstate_logic
		case (state)
		idle	:if (mode[1]==1'b1) nextstate=wkstk1; else nextstate=idle;
		wkstk1	:nextstate=wkstk2;
		wkstk2	:nextstate=wkstk3;
		wkstk3	:nextstate=sdtk;
		sdtk	:nextstate=enctk;
		enctk	:if (aes_rdy==1'b1) nextstate=wksd1; else nextstate=enctk;
		wksd1	:nextstate=wksd2;
		wksd2	:nextstate=wksd3;
		wksd3	:if (mode[0]==1'b0) nextstate=data; else nextstate=wksdec1;
		wksdec1 :nextstate=wksdec2;
		wksdec2 :nextstate=wksdec3;
		wksdec3 :nextstate=wksdec4;
		wksdec4 :nextstate=wksdec5;
		wksdec5 :nextstate=wksdec6;
		wksdec6 :nextstate=wksdec7;
		wksdec7 :nextstate=wksdec8;
		wksdec8 :nextstate=wksdec9;
		wksdec9 :nextstate=wksdec10;
		wksdec10 :nextstate=wksdec11;
		wksdec11 :nextstate=wksdec12;
		wksdec12 :nextstate=wksdec13;
		wksdec13 :nextstate=wksdec14;
		wksdec14 :nextstate=data;
		data	:if (mode[1]==1'b0) nextstate=idle; else nextstate=data;
		default :nextstate=idle;
		endcase
	end

	always_ff @ (posedge clk, negedge n_rst)
	begin :state_memory
		if (1'b0==n_rst)
		begin
			state<=idle;
		end
		else
		begin
			state<=nextstate;
		end
	end

	always_comb
	begin 
		if (state==idle)
		begin
			xex_bz=1'b1;
			d_valid=1'b0;
			d_tk=1'b1;
			tk_ud=1'b0;
			out_rdy=1'b0;
			enc_dec=1'b0;
		end
		if (state==wkstk1||state==wkstk2||state==wkstk3)
		begin
			xex_bz=1'b1;
			d_valid=1'b0;
			d_tk=1'b0;
			tk_ud=1'b0;
			out_rdy=1'b0;
			enc_dec=1'b0;
		end
		else if (state==sdtk)
		begin
			xex_bz=1'b1;
			d_valid=1'b1;
			d_tk=1'b0;
			tk_ud=1'b0;
			out_rdy=1'b0;
			enc_dec=1'b0;
		end
		else if (state==enctk)
		begin
			xex_bz=1'b1;
			d_valid=1'b0;
			d_tk=1'b0;
			tk_ud=aes_rdy;
			out_rdy=1'b0;
			enc_dec=1'b0;
		end/*
		else if (state==sddata)
		begin
			xex_bz=1'b1;
			d_valid=1'b1;
			d_tk=1'b1;
			tk_ud=1'b0;
			out_rdy=1'b0;
			enc_dec=1'b0;
		end*/
		else if (state==data)
		begin
			xex_bz=aes_bz;
			d_valid=in_rdy;
			d_tk=1'b1;
			tk_ud=1'b0;
			out_rdy=aes_rdy;
			enc_dec=mode[0];
		end
		else 
		begin
			xex_bz=1'b1;
			d_valid=1'b0;
			d_tk=1'b1;
			tk_ud=1'b0;
			out_rdy=1'b0;
			enc_dec=mode[0];
		end
	end

endmodule

