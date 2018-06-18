`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/11 15:34:00
// Design Name: 
// Module Name: Conv2d
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


module Conv2d #(
    parameter integer BITWIDTH = 8,
    
    parameter integer DATAWIDTH = 28,
    parameter integer DATAHEIGHT = 28,
    parameter integer DATACHANNEL = 3,
    
    parameter integer FILTERHEIGHT = 5,
    parameter integer FILTERWIDTH = 5,
    parameter integer FILTERBATCH = 1,
    
    parameter integer STRIDEHEIGHT = 1,
    parameter integer STRIDEWIDTH = 1,
    
    parameter integer PADDINGENABLE = 0
    )
    (
    //input clk,
    //input clken,
    input [BITWIDTH * DATAWIDTH * DATAHEIGHT * DATACHANNEL - 1 : 0]data,
    input [BITWIDTH * FILTERHEIGHT * FILTERWIDTH * DATACHANNEL * FILTERBATCH - 1 : 0]filterWeight,
    input [BITWIDTH * FILTERBATCH - 1 : 0] filterBias,
    output [(BITWIDTH * 2) * FILTERBATCH * (PADDINGENABLE == 0 ? (DATAWIDTH - FILTERWIDTH + 1) / STRIDEWIDTH : (DATAWIDTH / STRIDEWIDTH)) * (PADDINGENABLE == 0 ? (DATAHEIGHT - FILTERHEIGHT + 1) / STRIDEHEIGHT : (DATAHEIGHT / STRIDEHEIGHT)) - 1 : 0] result
    );
    
    wire [BITWIDTH - 1 : 0] dataArray[0 : DATACHANNEL - 1][0 : DATAHEIGHT-1][0 : DATAWIDTH - 1];
    wire [BITWIDTH - 1 : 0] dataArrayWithPadding[0 : DATACHANNEL - 1][0 : (PADDINGENABLE == 1 ? DATAHEIGHT + FILTERHEIGHT - 1 : DATAHEIGHT)-1][0 : (PADDINGENABLE == 1 ? DATAWIDTH + FILTERWIDTH - 1 : DATAWIDTH)-1];
    wire [BITWIDTH * FILTERHEIGHT * FILTERWIDTH * DATACHANNEL - 1 : 0] paramArray[0: (PADDINGENABLE == 1 ? DATAHEIGHT / STRIDEHEIGHT: (DATAHEIGHT - FILTERHEIGHT + 1) / STRIDEHEIGHT)-1][0: (PADDINGENABLE == 1 ? DATAWIDTH / STRIDEWIDTH : (DATAWIDTH - FILTERWIDTH + 1) / STRIDEWIDTH)-1];
    wire [BITWIDTH * DATACHANNEL * FILTERHEIGHT * FILTERWIDTH - 1 : 0] filterWeightArray[0: FILTERBATCH - 1];
 
    wire [(BITWIDTH * 2) * FILTERBATCH * (PADDINGENABLE == 0 ? (DATAWIDTH - FILTERWIDTH + 1) / STRIDEWIDTH : (DATAWIDTH / STRIDEWIDTH)) * (PADDINGENABLE == 0 ? (DATAHEIGHT - FILTERHEIGHT + 1) / STRIDEHEIGHT : (DATAHEIGHT / STRIDEHEIGHT)) - 1 : 0] out;
    
    genvar i, j, k, m, n;
    generate       
        for(i = 0; i < DATACHANNEL; i = i + 1) begin
            for(j = 0; j < DATAHEIGHT; j = j + 1) begin
                for(k = 0; k < DATAWIDTH; k = k + 1) begin
                    assign dataArray[i][j][k] = data[(i * DATAHEIGHT * DATAWIDTH + j * DATAHEIGHT + k) * BITWIDTH + BITWIDTH - 1:(i * DATAHEIGHT * DATAWIDTH + j * DATAHEIGHT + k) * BITWIDTH];
                end
            end
        end      
    endgenerate
    
    generate
        for(i = 0; i < DATACHANNEL; i = i + 1) begin
            for(m = 0; m < (PADDINGENABLE == 1 ? DATAHEIGHT + FILTERHEIGHT - 1 : DATAHEIGHT); m = m + 1) begin
                for(n = 0; n < (PADDINGENABLE == 1 ? DATAWIDTH + FILTERWIDTH - 1 : DATAWIDTH); n = n + 1) begin
                    if(PADDINGENABLE == 1) begin
                        if(m < (FILTERHEIGHT / 2) || m > (DATAHEIGHT + FILTERHEIGHT / 2 - 1)) begin
                            assign dataArrayWithPadding[i][m][n] = 0;
                        end
                        else if(n < (FILTERWIDTH / 2) || n > (DATAWIDTH + FILTERWIDTH / 2 - 1)) begin
                            assign dataArrayWithPadding[i][m][n] = 0;
                        end
                        else begin
                            assign dataArrayWithPadding[i][m][n] = dataArray[i][m - FILTERHEIGHT / 2][n - FILTERWIDTH / 2];
                        end
                    end
                    else begin
                        assign dataArrayWithPadding[i][m][n] = dataArray[i][m][n];
                    end
                end
            end
        end
    endgenerate
    
    generate
            for(j = FILTERHEIGHT / 2; j < (PADDINGENABLE == 1 ? DATAHEIGHT + FILTERHEIGHT - 1 - FILTERHEIGHT / 2: DATAHEIGHT - FILTERHEIGHT / 2); j = j + STRIDEHEIGHT) begin
                for(k = FILTERWIDTH / 2; k < (PADDINGENABLE == 1 ? DATAWIDTH + FILTERWIDTH - 1 - FILTERWIDTH / 2 : DATAWIDTH - FILTERWIDTH / 2); k = k + STRIDEWIDTH) begin
                    for(i = 0; i < DATACHANNEL; i = i + 1) begin
                        for(m = j - FILTERHEIGHT / 2; m <= j + FILTERHEIGHT / 2; m = m + 1) begin
                            for(n = k - FILTERWIDTH / 2; n <= k + FILTERWIDTH / 2; n = n + 1) begin
                                assign paramArray[(j - FILTERHEIGHT / 2) / STRIDEHEIGHT][(k - FILTERWIDTH / 2) / STRIDEWIDTH][(i * FILTERHEIGHT * FILTERWIDTH + (m - j + FILTERHEIGHT / 2) * FILTERWIDTH + (n - k + FILTERWIDTH / 2)) * BITWIDTH + BITWIDTH - 1:(i * FILTERHEIGHT * FILTERWIDTH + (m - j + FILTERHEIGHT / 2) * FILTERWIDTH + (n - k + FILTERWIDTH / 2)) * BITWIDTH] = 
                                    dataArrayWithPadding[i][m][n];
                            end
                        end
                    end
                end
            end
    endgenerate
    
    generate 
        for(i = 0; i < FILTERBATCH; i = i + 1) begin
            assign filterWeightArray[i] = filterWeight[(i + 1) * DATACHANNEL * FILTERHEIGHT * FILTERWIDTH * BITWIDTH - 1: i * DATACHANNEL * FILTERHEIGHT * FILTERWIDTH * BITWIDTH];
        end
    endgenerate
    
    generate
        for(i = 0; i < FILTERBATCH; i = i + 1) begin
            for(m = 0; m < (PADDINGENABLE == 1 ? DATAHEIGHT / STRIDEHEIGHT: (DATAHEIGHT - FILTERHEIGHT + 1) / STRIDEHEIGHT); m = m + 1) begin
                for(n = 0; n < (PADDINGENABLE == 1 ? DATAWIDTH / STRIDEWIDTH : (DATAWIDTH - FILTERWIDTH + 1) / STRIDEWIDTH); n = n + 1) begin
                        ConvKernel#(BITWIDTH, DATACHANNEL, FILTERHEIGHT, FILTERWIDTH) convKernel(paramArray[m][n], 
                        filterWeightArray[i], 
                        filterBias[(i + 1) * BITWIDTH - 1 :i * BITWIDTH],
                        result[(i * (PADDINGENABLE == 1 ? DATAHEIGHT / STRIDEHEIGHT: (DATAHEIGHT - FILTERHEIGHT + 1) / STRIDEHEIGHT) * (PADDINGENABLE == 1 ? DATAWIDTH / STRIDEWIDTH : (DATAWIDTH - FILTERWIDTH + 1) / STRIDEWIDTH) * BITWIDTH * 2 + m * (PADDINGENABLE == 1 ? DATAWIDTH / STRIDEWIDTH : (DATAWIDTH - FILTERWIDTH + 1) / STRIDEWIDTH) * BITWIDTH * 2 + n) * 2 * BITWIDTH + 2 * BITWIDTH - 1:(i * (PADDINGENABLE == 1 ? DATAHEIGHT / STRIDEHEIGHT: (DATAHEIGHT - FILTERHEIGHT + 1) / STRIDEHEIGHT) * (PADDINGENABLE == 1 ? DATAWIDTH / STRIDEWIDTH : (DATAWIDTH - FILTERWIDTH + 1) / STRIDEWIDTH) * BITWIDTH * 2 + m * (PADDINGENABLE == 1 ? DATAWIDTH / STRIDEWIDTH : (DATAWIDTH - FILTERWIDTH + 1) / STRIDEWIDTH) * BITWIDTH * 2 + n * 2 * BITWIDTH)]);
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
