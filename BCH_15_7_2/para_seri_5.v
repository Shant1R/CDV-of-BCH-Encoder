`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:15:29 03/29/2018 
// Design Name: 
// Module Name:    para_seri_5 
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
module piso(ps_out, ps_in, clk, reset, load
    );
	 input[6:0] ps_in;
    input clk, reset, load;    
    output ps_out;
    reg [6:0] temp_in;
    assign ps_out = temp_in[6];
    always @(posedge clk)
    begin 
       if (reset)
       begin
           temp_in <= 7'b0;
       end
       else
       begin
           if (load)
           temp_in <= ps_in;
           else
           begin
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
