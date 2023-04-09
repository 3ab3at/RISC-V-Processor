`timescale 1ns / 1ps

module Forwarding_Unit(
    output reg  [1:0]  forwardA, forwardB, 
    input  wire [31:0] ID_EX_RegisterRs1, ID_EX_RegisterRs2,
    input  wire [31:0] EX_MEM_RegisterRd, MEM_WB_RegisterRd, 
    input  wire EX_MEM_RegWrite, MEM_WB_RegWrite 
);
    
    always@(*) begin
            if (
                    ( MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && (MEM_WB_RegisterRd == ID_EX_RegisterRs1) )
                    &&  !( EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs1) )
               )
                        forwardA = 2'b01;   
           
           
            if (
                    EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
                    && (EX_MEM_RegisterRd == ID_EX_RegisterRs1) 
                )
                        forwardA = 2'b10;
        
        if (
            !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs1))
            && !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs1))
            )
            forwardA = 2'b00;
            
            
            if (
                    ( MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0)
                    && (MEM_WB_RegisterRd == ID_EX_RegisterRs2) )
                    && !( EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
                    && (EX_MEM_RegisterRd == ID_EX_RegisterRs2) )
                )
                        forwardB = 2'b01;    
           
           
           if ( 
                    EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
                    && (EX_MEM_RegisterRd == ID_EX_RegisterRs2)
                )
                        forwardB = 2'b10; 
       
       
       if ( !(
                                            ( MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0)
                                            && (MEM_WB_RegisterRd == ID_EX_RegisterRs2) )
                                            && !( EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
                                            && (EX_MEM_RegisterRd == ID_EX_RegisterRs2) )
                                        )
                                        &&
                    !( 
                                                            EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
                                                            && (EX_MEM_RegisterRd == ID_EX_RegisterRs2)
                                                        )
            )
            forwardB = 2'b00;

    end 
endmodule
