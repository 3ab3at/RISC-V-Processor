`timescale 1ns / 1ps

module Control_Unit (input [6:2] Ins, output reg Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, reg [1:0] ALUOp);
always@(*)
begin
    case (Ins)
        5'b01100: begin
        Branch = 1'b0;
        MemRead  = 1'b0;
        MemtoReg = 1'b0;
        ALUOp = 2'b10;
        ALUSrc = 1'b0;
        MemWrite = 1'b0;
        RegWrite = 1'b1;
        end
        5'b00000: begin
        Branch = 1'b0;
        MemRead  = 1'b1;
        MemtoReg = 1'b1;
        ALUOp = 2'b00;
        ALUSrc = 1'b1;
        MemWrite = 1'b0;
        RegWrite = 1'b1;
        end
        5'b01000: begin
        Branch = 1'b0;
        MemRead  = 1'b0;
        MemtoReg = 1'b0;
        ALUOp = 2'b00;
        ALUSrc = 1'b1;
        MemWrite = 1'b1;
        RegWrite = 1'b0;
        end
        5'b11000: begin
        Branch = 1'b1;
        MemRead  = 1'b0;
        MemtoReg = 1'b0;
        ALUOp = 2'b01;
        ALUSrc = 1'b0;
        MemWrite = 1'b0;
        RegWrite = 1'b0;
        end
    endcase
end
endmodule
