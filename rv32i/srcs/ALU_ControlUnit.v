/*******************************************************************
*
* Module: ALU_ControlUnit.v
* Author: Rana Elgahawy
*
**********************************************************************/
`timescale 1ns / 1ps

module ALU_ControlUnit (
    input wire b, [1:0] ALUOp, [2:0] fun,
    output reg [3:0] ALU_Sel 
);

    always@(*) begin
        case (ALUOp)
            2'b00: ALU_Sel = 4'b0000;
            2'b01: ALU_Sel = 4'b0001;
            2'b10: begin
                case (fun)
                    3'b000: begin
                        ALU_Sel = (b == 0)? 4'b0000 : 4'b0001; 
                    end
                    3'b111: ALU_Sel = 4'b0101;
                    3'b110: ALU_Sel = 4'b0100;
                    3'b101: begin 
                        if (b == 1) ALU_Sel = 4'b1001;  else ALU_Sel = 4'b1000; 
                    end
                    3'b100: ALU_Sel = 4'b0111;
                    3'b010: ALU_Sel = 4'b1101;
                    3'b011: ALU_Sel = 4'b1111;
                    3'b001: ALU_Sel = 4'b1010;
                    default: ALU_Sel = 0;   
                endcase    
           end
           2'b11: begin
                case (fun)
                   3'b000: ALU_Sel = 4'b0000;
                   3'b111: ALU_Sel = 4'b0101;
                   3'b110: ALU_Sel = 4'b0100;
                   3'b101: begin 
                       if (b == 1) ALU_Sel = 4'b1001;  else ALU_Sel = 4'b1000; 
                   end
                   3'b100: ALU_Sel = 4'b0111;
                   3'b010: ALU_Sel = 4'b1101;
                   3'b011: ALU_Sel = 4'b1111;
                   3'b001: ALU_Sel = 4'b1010;
                   default: ALU_Sel = 0;   
               endcase            
          end
          default: ALU_Sel=0;   
        endcase
    end
endmodule
