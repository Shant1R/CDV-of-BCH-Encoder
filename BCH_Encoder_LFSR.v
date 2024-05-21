`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:55:42 03/29/2018 
// Design Name: 
// Module Name:    BCH_Encoder_LFSR 
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
module BCHEncoder(out, msg, clk, reset, active_encoder);
    output[0:14] out;
    input[6:0] msg;
    input clk, reset,active_encoder;
    wire en_out,ps_out;
    reg [4:0] ctrl;
    reg init, hold, load, switch;
    initial ctrl = 5'b0;
always@ (posedge clk)
begin
    if(active_encoder)
       ctrl <= ctrl + 1;
    else
       ctrl<= 5'b0;
end
always@ (posedge clk)
begin
    if(reset)
    begin
        init = 0;
        load = 0;
        hold = 0;
        switch = 0;
    end
    else if(ctrl==0)
    begin
        init = 1;
        load = 1;
        hold = 0;
        switch =0;
    end
    else if(ctrl == 1)
    begin
        init = 0;
        load = 1;
        hold = 0;
    end
    else if(ctrl == 2)
    begin
        init = 0;
        load = 0;
        hold = 0;
        switch = 1;
    end
    else if(ctrl == 9)
    begin
        init = 0;
        load = 0;
        hold = 0;
        switch = 0;
    end
     else if(ctrl == 17)
    begin
        init = 0;
        load = 0;
        hold = 1;
    end
end
       piso ps1(ps_out, msg, clk, reset, load);    
       encoder_LFSR b(en_out, ps_out, clk, reset, switch, init);
       sipo sp(out, en_out, clk, reset, hold);
endmodule
