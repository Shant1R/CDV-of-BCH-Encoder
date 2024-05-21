`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:25:11 03/29/2018 
// Design Name: 
// Module Name:    seri_paral_15 
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
module sipo(sp_out, sp_in, clk, reset, hold
    );
    input sp_in, clk, reset, hold;
    output [0:14] sp_out;
    reg[14:0] r;
       assign sp_out = r;
       always @(posedge clk)          
          begin
              if (reset)
              r<= 15'b000_0000_0000_0000;
              else if(hold)
              r<= r;
              else
              r<= {sp_in,r[14:1]};
          end
endmodule
