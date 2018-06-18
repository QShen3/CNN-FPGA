`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/16 16:57:49
// Design Name: 
// Module Name: Relu_activation
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


module Relu_activation#(
    parameter integer BITWIDTH = 8,

    parameter integer DATAWIDTH = 28,
    parameter integer DATAHEIGHT = 28,
    parameter integer DATACHANNEL = 3
    )
    (
    //input clk,
    //input clken,
    input [BITWIDTH * DATAHEIGHT * DATAWIDTH * DATACHANNEL - 1:0] data,
    output reg [BITWIDTH * DATAHEIGHT * DATAWIDTH * DATACHANNEL - 1:0] result
    );
    
    //wire [BITWIDTH * DATAHEIGHT * DATAWIDTH * DATACHANNEL - 1:0] out;
    
    genvar i, j, k;
    generate
        for(i = 0; i < DATACHANNEL; i = i + 1) begin
            for(j = 0; j < DATAHEIGHT; j = j + 1) begin
                for(k = 0; k < DATAWIDTH; k = k + 1) begin
                    Relu#(BITWIDTH) relu(data[(i * DATAHEIGHT * DATAWIDTH + j * DATAWIDTH + k) * BITWIDTH + BITWIDTH - 1:(i * DATAHEIGHT * DATAWIDTH + j * DATAWIDTH + k) * BITWIDTH], result[(i * DATAHEIGHT * DATAWIDTH + j * DATAWIDTH + k) * BITWIDTH + BITWIDTH - 1:(i * DATAHEIGHT * DATAWIDTH + j * DATAWIDTH + k) * BITWIDTH]);
                end
            end
        end
    endgenerate

    // always @(posedge clk) begin
    //     if(clken == 1) begin
    //         result = out;
    //     end
    // end    
    
endmodule
