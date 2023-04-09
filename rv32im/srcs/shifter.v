/*******************************************************************
*
* Module: shifter.v
* Author: Abdelaaty Rehab
*
**********************************************************************/
`timescale 1ns / 1ps

module shifter (
    input wire [31:0]   a,
    input wire [4:0]    shamt,
    input wire [1:0]    type,
    output reg [31:0]   r
);
    always @(*) begin
        case(type)
            2'b00: r = a >> shamt;
            2'b01: r = a >>> shamt;
            2'b11: r = a << shamt;   
            default: r = 0;  
       endcase
    end
endmodule
