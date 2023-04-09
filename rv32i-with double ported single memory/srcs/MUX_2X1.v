`timescale 1ns / 1ps

module MUX_4X1(input wire [31:0] A, B, C, D, input wire [1:0] S, output reg [31:0] Z);
    always @(*) begin
        case(S) 
            0: Z = A;
            1: Z = B;
            2: Z = C;
            3: Z = D;
        endcase
    end
endmodule

