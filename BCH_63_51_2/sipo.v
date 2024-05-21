`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:25:47 05/14/2018 
// Design Name: 
// Module Name:    sipo 
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
module sipo(sp_out, sp_in, clk, reset, hold);
input sp_in, clk, reset, hold;
    output [0:62] sp_out;
    reg[62:0] r;
       assign sp_out = r;
       always @(posedge clk)          
          begin
              if (reset)
              r<= 63'b0;
              else if(hold)
              r<= r;
              else
              r<= {sp_in,r[62:1]};
          end
endmodule
