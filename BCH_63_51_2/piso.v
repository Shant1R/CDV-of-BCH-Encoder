`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:25:16 05/14/2018 
// Design Name: 
// Module Name:    piso 
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
module piso(ps_out, ps_in, clk, reset, load);
input[50:0] ps_in;
    input clk, reset, load;    
    output ps_out;
    reg [50:0] temp_in;
    assign ps_out = temp_in[50];
    always @(posedge clk)
    begin 
       if (reset)
       begin
           temp_in <= 51'b0;
       end
       else
       begin
           if (load)
           temp_in <= ps_in;
           else
           begin
					temp_in[50] <= temp_in[49];
					temp_in[49] <= temp_in[48];
					temp_in[48] <= temp_in[47];
					temp_in[47] <= temp_in[46];
					temp_in[46] <= temp_in[45];
					temp_in[45] <= temp_in[44];
					temp_in[44] <= temp_in[43];
					temp_in[43] <= temp_in[42];
					temp_in[42] <= temp_in[41];
					temp_in[41] <= temp_in[40];
					temp_in[40] <= temp_in[39];
					temp_in[39] <= temp_in[38];
					temp_in[38] <= temp_in[37];
					temp_in[37] <= temp_in[36];
					temp_in[36] <= temp_in[35];
					temp_in[35] <= temp_in[34];
					temp_in[34] <= temp_in[33];
					temp_in[33] <= temp_in[32];
					temp_in[32] <= temp_in[31];
					temp_in[31] <= temp_in[30];
					temp_in[30] <= temp_in[29];
					temp_in[29] <= temp_in[28];
					temp_in[28] <= temp_in[27];
					temp_in[27] <= temp_in[26];
					temp_in[26] <= temp_in[25];
					temp_in[25] <= temp_in[24];
					temp_in[24] <= temp_in[23];
					temp_in[23] <= temp_in[22];
					temp_in[22] <= temp_in[21];
					temp_in[21] <= temp_in[20];
					temp_in[20] <= temp_in[19];
					temp_in[19] <= temp_in[18];
					temp_in[18] <= temp_in[17];
					temp_in[17] <= temp_in[16];
					temp_in[16] <= temp_in[15];
					temp_in[15] <= temp_in[14];
					temp_in[14] <= temp_in[13];
					temp_in[13] <= temp_in[12];
					temp_in[12] <= temp_in[11];
					temp_in[11] <= temp_in[10];
					temp_in[10] <= temp_in[09];
					temp_in[09] <= temp_in[08];
					temp_in[08] <= temp_in[07];
					temp_in[07] <= temp_in[06];
										
					temp_in[6] <= temp_in[5];
					temp_in[5] <= temp_in[4];
               temp_in[4] <= temp_in[3];
               temp_in[3] <= temp_in[2];
               temp_in[2] <= temp_in[1];
               temp_in[1] <= temp_in[0];
               temp_in[0] <= 1'b0;
           end
       end
   end

endmodule
