/*******************************************************************
*
* Module: Control_Unit.v
* Author: Abdelaaty Rehab
*
**********************************************************************/
`timescale 1ns / 1ps

module Control_Unit (
    input wire [31:0] Ins, 
    output reg Branch, MemRead, reg [2:0] WhichReg,
    output reg MemWrite, ALUSrc, RegWrite, Jump,
    output reg [1:0] ALUOp
);
    always@(*) begin
        if (Ins == 32'b0) begin
            Branch = 1'b0;
            MemRead  = 1'b0;
            WhichReg = 3'b000;
            ALUOp = 2'b00;
            ALUSrc = 1'b0;
            MemWrite = 1'b0;
            RegWrite = 1'b0; 
            Jump = 1'b0;             
        end
        else begin
            case (Ins[6:2])
                //R-type
                5'b01100: begin
                    Branch = 1'b0;
                    MemRead  = 1'b0;
                    WhichReg = 3'b000;
                    ALUOp = 2'b10;
                    ALUSrc = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b1;
                    Jump = 1'b0;
                end
                // I type
                5'b00100: begin
                    Branch = 1'b0;
                    MemRead  = 1'b0;
                    WhichReg = 3'b000;
                    ALUOp = 2'b11;
                    ALUSrc = 1'b1;
                    MemWrite = 1'b0;
                    RegWrite = 1'b1;
                    Jump = 1'b0;
                end
                // Load
                5'b00000: begin
                    Branch = 1'b0;
                    MemRead  = 1'b1;
                    WhichReg = 3'b001;
                    ALUOp = 2'b00;
                    ALUSrc = 1'b1;
                    MemWrite = 1'b0;
                    RegWrite = 1'b1;
                    Jump = 1'b0;
                end
                // Store
                5'b01000: begin
                    Branch = 1'b0;
                    MemRead  = 1'b0;
                    WhichReg = 3'b000; // DONT CARE
                    ALUOp = 2'b00;
                    ALUSrc = 1'b1;
                    MemWrite = 1'b1;
                    RegWrite = 1'b0;
                    Jump = 1'b0;
                end
                // Branch
                5'b11000: begin
                    Branch = 1'b1;
                    MemRead  = 1'b0;
                    WhichReg = 3'b000; // DONT CARE
                    ALUOp = 2'b01;
                    ALUSrc = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b0;
                    Jump = 1'b0;
                end
                // LUI
                5'b011011: begin
                    Branch = 1'b0;
                    MemRead  = 1'b0;
                    WhichReg = 3'b011;
                    ALUOp = 2'b00; // DONT CARE
                    ALUSrc = 1'b1;
                    MemWrite = 1'b0;
                    RegWrite = 1'b1;
                    Jump = 1'b0;           
                end
                // AUI PC
                5'b00101: begin
                    Branch = 1'b0;
                    MemRead  = 1'b0;
                    WhichReg = 3'b100;
                    ALUOp = 2'b00;
                    ALUSrc = 1'b1;
                    MemWrite = 1'b0;
                    RegWrite = 1'b1; 
                    Jump = 1'b0;               
                end
                // JAL
                5'b11011: begin
                    Branch = 1'b1;
                    MemRead  = 1'b0;
                    WhichReg = 3'b010;
                    ALUOp = 2'b00;
                    ALUSrc = 1'b1;
                    MemWrite = 1'b0;
                    RegWrite = 1'b1;  
                    Jump = 1'b1;              
                end
                // JALR
                5'b11001: begin
                    Branch = 1'b1;
                    MemRead  = 1'b0;
                    WhichReg = 3'b010;
                    ALUOp = 2'b00;
                    ALUSrc = 1'b1;
                    MemWrite = 1'b0;
                    RegWrite = 1'b1; 
                    Jump = 1'b1;               
                end
            endcase
        end
    end
endmodule
