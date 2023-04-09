/*******************************************************************
*
* Module: mux.v
* Author: Rana Elgahawy
*
**********************************************************************/
module mux(input A, input B, input S, output C);
    assign C = (~S & A) | (S & B);
endmodule