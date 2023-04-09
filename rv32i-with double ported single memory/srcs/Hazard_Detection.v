`timescale 1ns / 1ps

module Hazard_Detection(
    output reg stall, 
    input wire [31:0] IF_ID_RegisterRs1, IF_ID_RegisterRs2, ID_EX_RegisterRd, ID_EX_MemRead
);
    always@(*) begin
        if (
                ( (IF_ID_RegisterRs1==ID_EX_RegisterRd) || (IF_ID_RegisterRs2==ID_EX_RegisterRd) )
                && ID_EX_MemRead && ID_EX_RegisterRd != 0
            )
                stall = 1'b1 ;
        else    stall = 1'b0;

    end
endmodule
