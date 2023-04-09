/*******************************************************************
*
* Module: ALU_ControlUnit.v
* Author: Rana Elgahawy
*
**********************************************************************/
module ALU_ControlUnit (
    input wire b, M, [1:0] ALUOp, [2:0] fun,
    output reg [3:0] ALU_Sel 
);

    always@(*) begin
        if(!M) begin
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
        else begin
            case(fun)
                3'b000: ALU_Sel = 4'b00_00;     //MUL
                3'b001: ALU_Sel = 4'b00_01;     //MULH
                3'b010: ALU_Sel = 4'b00_10;     //MULHSU
                3'b011: ALU_Sel = 4'b00_11;     //MULHU
                3'b100: ALU_Sel = 4'b11_00;     //DIV
                3'b101: ALU_Sel = 4'b11_01;     //DIVU
                3'b110: ALU_Sel = 4'b11_10;     //REM
                3'b111: ALU_Sel = 4'b11_11;     //REMU  
            endcase
        end
    end
endmodule
