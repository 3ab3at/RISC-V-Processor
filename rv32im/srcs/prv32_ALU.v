/*******************************************************************
*
* Module: prv32_ALU.v
* Author: Abdelaaty Rehab
*
**********************************************************************/
`timescale 1ns / 1ps

module prv32_ALU(
      input M;
	input   wire [31:0] a, b,
//	input   wire [4:0]  shamt,
	output  reg  [31:0] r,
	output  wire        cf, zf, vf, sf,
	input   wire [3:0]  alufn
);

    wire [31:0] add, sub, op_b;
    wire [4:0]  shamt;
    wire cfa, cfs;
    wire [63:0] div, mul, divs, muls, mulsu, as, bs;
    assign as = {{32{a[31]}},a};
    assign bs = {{32{b[31]}},b};
    assign div = a/b;
    assign mul = a*b;
    assign divs = as/bs;
    assign muls = as*bs;
    assign mulsu = as*b;

    assign op_b = (~b);
    assign div = a/b;
    assign mul = a*b;
    assign shamt = b[4:0];
    
    assign {cf, add} = alufn[0] ? (a + op_b + 1'b1) : (a + b);
    
    assign zf = (add == 0);
    assign sf = add[31];
    assign vf = (a[31] ^ (op_b[31]) ^ add[31] ^ cf);
    
    wire[31:0] sh;
    shifter shifter0(.a(a), .shamt(shamt), .type(alufn[1:0]),  .r(sh));
    
    always @ (*) begin
        r = 0;
        (* parallel_case *)
        case (alufn)
            if(!M) begin
            // arithmetic
            4'b00_00 : r = add;
            4'b00_01 : r = add;
            4'b00_11 : r = b;
            // logic
            4'b01_00:  r = a | b;
            4'b01_01:  r = a & b;
            4'b01_11:  r = a ^ b;
            // shift
            4'b10_00:  r=sh; // SRL
            4'b10_01:  r=sh; // SRA
            4'b10_10:  r=sh; // SLL
            // slt & sltu
            4'b11_01:  r = {31'b0,(sf != vf)}; 
            4'b11_11:  r = {31'b0,(~cf)};   
            end
            else begin
            //M estension
            4'b00_00:   r = muls[31:0];      //MUL
            4'b00_01:   r = muls[63:32];   //MULH
            4'b00_10:   r = mulsu[63:32];  //MULHSU
            4'b00_11:   r = mul[63:32];     //MULHU
            4’b11_00:   r= div [31:0];
            4’b11_01:    r= divu[31:0];
            4’b11_10:    r= a%b;
            4’b11_11:     r = as%bs;

             end
        endcase
    end
endmodule