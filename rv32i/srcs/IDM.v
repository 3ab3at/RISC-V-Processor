/*******************************************************************
*
* Module: IDM.v
* Author: Abdelaaty Rehab
*
**********************************************************************/
`timescale 1ns / 1ps

module IDM(
    input  wire        clk, MemRead, MemWrite, 
    input  wire [39:0] addr, 
    input  wire [02:0] func,
    input  wire [31:0] data_in, 
    output reg [31:0] data_out
);
    reg [31:0] IM [0:63];
    reg [31:0] DM [0:63];
        
    wire [31:0] next_inst;
       
    reg [31:0] real_addr;

    always @(addr, func) begin
        case(func) 
            3'b000:  real_addr = (addr[39:32]); // LB
            3'b001:  real_addr = ((addr[39:32]) >> 1); // LH
            3'b010:  real_addr = ((addr[39:32]) >> 2); // LW
            3'b100:  real_addr = (addr[39:32]); //LBU
            3'b101:  real_addr = ((addr[39:32]) >> 1); //LHU
            default: real_addr =  (addr[39:32]);
        endcase
    end

    always@(negedge clk, MemRead, real_addr) begin
        if(MemWrite)
            DM[real_addr] = data_in;
        else if (MemRead) begin
            case(func)
                3'b000: data_out = {{24{DM[real_addr][7]}},{DM[real_addr][7:0]}};
                3'b001: data_out = {{16{DM[real_addr][15]}},{DM[real_addr][15:0]}};
                3'b010: data_out = DM[real_addr];
                3'b100: data_out = {{24{1'b0}},{DM[real_addr][7:0]}};
                3'b101: data_out = {{16{1'b0}},{DM[real_addr][15:0]}};
            endcase        
        end
    end

    always @(posedge clk) begin
        data_out = IM[(addr[31:0]) >> 2];
    end

    reg [31:0] x [0:31];

    initial begin
        $readmemh("./tests/test1.hex", x);
    end
   
    integer i;
    initial begin
        for (i = 0; i < 32; i = i+1)
            {IM[(i * 4) + 3], IM[(i * 4) + 2], IM[(i * 4) + 1], IM[i * 4]} = x[i]; // depends on endianity
    end
        
//    initial begin 
//        DM[0]=32'd17;
//        DM[1]=32'd9;
//        DM[2]=32'd25;
//    end
    
//    initial begin
//        IM[0]=32'b000000000000_00000_010_00001_0000011 ; //lw x1, 0(x0)
//        IM[1]=32'b000000000100_00000_010_00010_0000011 ; //lw x2, 4(x0)
//        IM[2]=32'b000000001000_00000_010_00011_0000011 ; //lw x3, 8(x0)
//        IM[3]=32'b0000000_00010_00001_110_00100_0110011 ; //or x4, x1, x2
//        IM[4]=32'b0_000000_00011_00100_000_0100_0_1100011; //beq x4, x3, 4
//        IM[5]=32'b0000000_00010_00001_000_00011_0110011 ; //add x3, x1, x2
//        IM[6]=32'b0000000_00010_00011_000_00101_0110011 ; //add x5, x3, x2
//        IM[7]=32'b0000000_00101_00000_010_01100_0100011; //sw x5, 12(x0)
//        IM[8]=32'b000000001100_00000_010_00110_0000011 ; //lw x6, 12(x0)
//        IM[9]=32'b0000000_00001_00110_111_00111_0110011 ; //and x7, x6, x1
//        IM[10]=32'b0100000_00010_00001_000_01000_0110011 ; //sub x8, x1, x2
//        IM[11]=32'b0000000_00010_00001_000_00000_0110011 ; //add x0, x1, x2
//        IM[12]=32'b0000000_00001_00000_000_01001_0110011 ; //add x9, x0, x1 
//    end
endmodule
