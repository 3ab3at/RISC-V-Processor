/*******************************************************************
*
* Module: Forwarding_Unit.v
* Author: Abdelaaty Rehab
*
**********************************************************************/
`timescale 1ns / 1ps

module Forwarding_Unit(
    output reg         forwardA, forwardB, 
    input  wire [31:0] ID_EX_RegisterRs1, ID_EX_RegisterRs2,
    input  wire [31:0] MEM_WB_RegisterRd, 
    input  wire MEM_WB_RegWrite 
);
    
    always@(*) begin
            if (
                    ( MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) 
                    && (MEM_WB_RegisterRd == ID_EX_RegisterRs1) )
               )
                        forwardA = 1'b1;  
            else        forwardA = 1'b0;
                        
            if (
                    ( MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0)
                    && (MEM_WB_RegisterRd == ID_EX_RegisterRs2) )
                )
                        forwardB = 1'b1;   
             else       forwardB = 1'b0;
    end 
endmodule
