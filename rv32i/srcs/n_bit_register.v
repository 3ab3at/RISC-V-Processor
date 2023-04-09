/*******************************************************************
*
* Module: n_bit_register.v
* Author: Rana Elgahawy
*
**********************************************************************/
module n_bit_register #(parameter n = 8) (
    input [n-1:0] D, 
    input rst, Load, clk, 
    output [n-1:0] Q
);
    genvar i;
    wire[n-1:0] DD;
    generate
        for(i = 0; i < n; i = i+1) begin: myblockname
            mux m( Q[i],D[i],  Load, DD[i]);
            DFF dflpflop(clk, rst, DD[i], Q[i]);	
        end
    endgenerate
endmodule