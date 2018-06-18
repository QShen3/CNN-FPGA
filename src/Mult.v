`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/11 16:17:19
// Design Name: 
// Module Name: Mult
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Mult#(
    parameter BITWIDTH = 8
    )
    (
    input signed [BITWIDTH-1:0] a,
    input signed [BITWIDTH-1:0] b,
    output signed [BITWIDTH * 2 - 1:0] c
    );
    
    assign c = a * b;
    //assign c = 1;
    
endmodule
