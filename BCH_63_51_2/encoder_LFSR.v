`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:25:32 05/14/2018 
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
module encoder_LFSR(dout,din, clk, reset, switch, init);
output dout;
    input din, clk, reset, switch, init;
    reg d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11;
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
			d8<= 1'b0;
			d9<= 1'b0;
			d10<=1'b0;
			d11<=1'b0;
			
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
			d8<= 1'b0;
			d9<= 1'b0;
			d10<=1'b0;
			d11<=1'b0;
			
	  end
	  else
	  begin
		  d0<= df;
		  d1<= d0;
		  d2<= d1;
		  d3<= d2^df;
		  d4<= df^d3;
		  d5<= d4^df;
		  d6<= d5;
		  d7<= d6;	
		  d8<= d7^df;
		  d9<= d8;
		  d10<= d9^df;
		  d11<= d10;
		  
	  end
	end
   always@(switch,din,d11)
   begin
		if(switch)
		begin
			df<= din^d11;
			dout<=din;
		end		
		else
		begin
			df<=1'b0;
			dout<= d11;
		end
	end
endmodule
