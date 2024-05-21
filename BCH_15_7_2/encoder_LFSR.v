`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:17:12 03/29/2018 
// Design Name: 
// Module Name:    encoder_LFSR 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module encoder_LFSR(dout,din, clk, reset, switch, init
    );
    output dout;
    input din, clk, reset, switch, init;
    reg d0, d1, d2, d3, d4, d5, d6, d7;
    reg df, dout;
    always@(posedge clk)
    begin
	   if(reset)
	   begin
		   d0<= 1'b0;
		   d1<= 1'b0;
		   d2<= 1'b0;
		   d3<= 1'b0;
		   d4<= 1'b0;
		   d5<= 1'b0;
		   d6<= 1'b0;
		   d7<= 1'b0;
	  end
	  else if(init)
	   begin
		   d0<= 1'b0;
		   d1<= 1'b0;
		   d2<= 1'b0;
		   d3<= 1'b0;
		   d4<= 1'b0;
		   d5<= 1'b0;
		   d6<= 1'b0;
		   d7<= 1'b0;
	  end
	  else
	  begin
		  d0<= df;
		  d1<= d0;
		  d2<= d1;
		  d3<= d2;
		  d4<= df^d3;
		  d5<= d4;
		  d6<= df^d5;
		  d7<= df^d6;	
	  end
	end
   always@(switch,din,d7)
   begin
		if(switch)
		begin
			df<= din^d7;
			dout<=din;
		end		
		else
		begin
			df<=1'b0;
			dout<= d7;
		end
	end
endmodule
