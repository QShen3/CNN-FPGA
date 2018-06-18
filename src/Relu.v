`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/16 16:52:03
// Design Name: 
// Module Name: Relu
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


module Relu#(
    parameter BITWIDTH = 8,
    parameter THRESSHOLD = 0
    )
    (
    input signed [BITWIDTH - 1:0] data,
    output signed [BITWIDTH - 1:0] result
    );
    
    assign result = data > THRESSHOLD ? data : THRESSHOLD;
endmodule
