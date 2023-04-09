`timescale 1ns / 1ps

module ALU_ControlUnit (input b, [1:0] ALUOp, [2:0] fun, output reg [3:0] ALU_Sel );

always@(*)
begin
    case (ALUOp)
        2'b00: ALU_Sel = 4'b0010;
        2'b01: ALU_Sel = 4'b0110;
        2'b10: begin
        case (fun)
             3'b000: 
            begin ALU_Sel = (b == 0)? 4'b0010 : 4'b0110; end
             3'b111:
                begin if (b == 0) ALU_Sel = 4'b0000; else ALU_Sel=0; end
            3'b110: 
            begin if (b == 0) ALU_Sel = 4'b0001;   else ALU_Sel=0; end
          default: ALU_Sel=0;   
          endcase    
        end
      default: ALU_Sel=0;   
    endcase
end
endmodule
