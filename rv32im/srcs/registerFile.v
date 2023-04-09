/*******************************************************************
*
* Module: registerFile.v
* Author: Rana Elgahawy
*
**********************************************************************/
`timescale 1ns / 1ps

module registerFile #(parameter n = 8) (
    input wire clk, rst , RegWrite, 
    input wire [4:0] ReadReg1, ReadReg2, WriteReg, 
    input wire [n - 1:0] WriteData, 
    output reg [n - 1:0] ReadData1, ReadData2
);
  
    wire [n-1:0] Q [31:0];
    reg [31:0] load;  

    always@(*) begin
        load = 32'd0;
        load [WriteReg] = (WriteReg)? RegWrite : 0;
    end

    always@(*) begin
        ReadData1 = Q [ReadReg1];
        ReadData2 = Q [ReadReg2];
    end

    genvar i;  
    generate
        for (i = 0; i < 32; i = i+1) begin: myblockname
           n_bit_register #(32) nb(WriteData, rst, load[i], clk,  Q[i]);
        end
    endgenerate
endmodule
