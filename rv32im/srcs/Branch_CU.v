/*******************************************************************
*
* Module: Branch_CU.v
* Author: Abdelaaty Rehab & Rana Elgahawy
*
**********************************************************************/
`timescale 1ns / 1ps

module Branch_CU(
    input wire [2:0] fun,
    input wire zf, cf, vf, sf,
    output reg flag
);
    always @(*) begin
        case(fun)
            3'b000: flag = (zf) ? 1'b1 : 1'b0; //BEQ
            3'b001: flag = (zf) ? 1'b0 : 1'b1; // BNE
            3'b100: flag = (sf == vf) ? 1'b0 : 1'b1; // BLT
            3'b101: flag = (sf == vf) ? 1'b1 : 1'b0;    // BGE
            3'b110: flag = (cf) ? 1'b0 : 1'b1;   //BLTU
            3'b111: flag = (cf) ? 1'b1 : 1'b0;        // BGEU
            default: flag = 1'b0;
        endcase
    end
endmodule
