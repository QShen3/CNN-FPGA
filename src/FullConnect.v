`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/18 13:47:58
// Design Name: 
// Module Name: FullConnect
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


module FullConnect#(
    parameter BITWIDTH = 8,
    
    parameter LENGTH = 25,
    
    parameter FILTERBATCH = 1
    )
    (
    //input clk,
    //input clken,
    input [BITWIDTH * LENGTH - 1 : 0] data,
    input [BITWIDTH * LENGTH * FILTERBATCH - 1 : 0] weight,
    input [BITWIDTH * FILTERBATCH - 1 : 0] bias,
    output [BITWIDTH * 2 * FILTERBATCH - 1 : 0] result
    );
    
    //reg [BITWIDTH * 2 * LENGTH * FILTERBATCH- 1:0] out;
    wire [BITWIDTH * 2 - 1:0] out [0:FILTERBATCH - 1][0:LENGTH - 1];
    wire signed [BITWIDTH - 1:0] biasArray[0:FILTERBATCH - 1];
    reg signed [BITWIDTH * 2 - 1:0] resultArray [0:FILTERBATCH - 1];
    
    //wire [BITWIDTH * 2 * FILTERBATCH - 1 : 0] out2;
    
    genvar i, j;
    generate
        for(i = 0; i < FILTERBATCH; i = i + 1) begin
            assign biasArray[i] = bias[(i + 1) * BITWIDTH - 1: i * BITWIDTH];
            assign result[(i + 1) * BITWIDTH * 2 - 1: i * BITWIDTH * 2] = resultArray[i];
        end
    endgenerate
    
    generate 
        for(i = 0; i < FILTERBATCH; i = i + 1) begin
            for(j = 0; j < LENGTH; j = j + 1) begin
                Mult#(BITWIDTH) mult(data[(j + 1) * BITWIDTH - 1:j * BITWIDTH], weight[(i * LENGTH + j) * BITWIDTH + BITWIDTH - 1 : (i * LENGTH + j) * BITWIDTH], out[i][j]);
            end
        end
    endgenerate
    
    integer sum, m, n;
    always @(*) begin
        for(m = 0; m < FILTERBATCH; m = m + 1) begin
            sum = 0;
            for(n = 0; n < LENGTH; n = n + 1) begin
                sum = sum + out[m][n];
            end
            sum = sum + biasArray[m];
            resultArray[m] = sum;
        end
    end
    
    // always @(posedge clk) begin
    //     if(clken == 1) begin
    //         result = out2;
    //     end
    // end 
    
endmodule
