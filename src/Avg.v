`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/15 14:18:06
// Design Name: 
// Module Name: Avg
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


module Avg#(
    parameter BITWIDTH = 8,
    parameter LENGTH = 4
    )
    (
    input [BITWIDTH * LENGTH - 1 : 0] data,
    output reg signed [BITWIDTH - 1 : 0] result
    );
    
    wire signed [BITWIDTH - 1:0] dataArray[0:LENGTH - 1];
    genvar i;
    generate      
        for(i = 0; i < LENGTH; i = i + 1) begin
            assign dataArray[i] = data[i * BITWIDTH + BITWIDTH - 1: i * BITWIDTH];
        end
    endgenerate
    
    integer j, sum;
    always @(*) begin
        sum = 0;
        for(j = 0; j < LENGTH; j = j + 1) begin
            sum = sum + dataArray[j];
        end
        result = sum / LENGTH;
    end
    
endmodule
