/*******************************************************************
*
* Module: rv32_CPU.v
* Author: Abdelaaty Rehab & Rana Elgahawy
*
**********************************************************************/
`timescale 1ns / 1ps
`include "defines.v"

module rv32_CPU( 
    input wire clk, 
    rst
);
    wire Branch, MemRead, RegWrite, MemWrite, ALUSrc, Jump, Branchflag;
    wire [2:0] WhichReg;
    wire [1:0] ALUOp;
    reg  [31:0] WriteData; //from mux
    wire [31:0] ReadData1, ReadData2, ReadData, EX_MEM_PC_Branch, EX_MEM_PC_JAL, MEM_WB_Rd, EX_MEM_Ctrl, EX_MEM_PC_JALR, EX_MEM_Func;
    wire [31:0] gen_out, ALUResult;
    wire [3:0] ALU_Sel;
    wire [31:0] MUX_ALU;
    wire zf, cf, vf, sf, flush_pipeline;
    reg  [31:0] PC;
    wire [31:0] MEM_WB_Ctrl;
    wire [31:0] BranchAddress, JALAddress, JALRAddress;
    wire [31:0] Add4;
    reg  [31:0] next_PC;
    reg  [12:0] SSD;
    wire [1:0] JB;
    
    assign JB = {EX_MEM_Ctrl[5], EX_MEM_Ctrl[0]};
    assign Add4 = 4 + PC;

    always @(*) begin
        if (~((ReadData[6:0] == 7'b1110011)&&(ReadData[20] == 1'b1)))
                case(JB) 
                    2'b00: begin 
                    if ((ReadData[6:0] == 7'b0001111) || ((ReadData[6:0] == 7'b1110011)& (ReadData[20] == 1'b0)))
                        next_PC = 0;
                    else    
                        next_PC = Add4;
                    end
                    2'b01: next_PC = (Branchflag) ? EX_MEM_PC_Branch : Add4;
                    2'b10: next_PC = (EX_MEM_Func[30]) ?  JALAddress : JALRAddress;
                    default: next_PC = Add4;
                endcase
        else 
            next_PC = PC;  
    end

    always@(posedge clk or posedge rst) begin
     if (rst) PC = 0;
     else 
        PC = next_PC;
    end
    
    wire [31:0] IF_ID_PC, IF_ID_Inst; 
            
    n_bit_register #(64) IF_ID_REG ({ReadData, PC}, rst, 1'b1, ~clk, {IF_ID_Inst, IF_ID_PC});

    /////////////////////////////// end of fetching stage ////////////////////////////////////////////////
    
    wire [31:0] ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm;
    wire [31:0] ID_EX_Ctrl;
    wire [31:0] ID_EX_Func;
    wire [31:0] ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd; 
        
    Control_Unit CU (IF_ID_Inst, Branch, MemRead, WhichReg, MemWrite, ALUSrc, RegWrite, Jump, ALUOp);
    registerFile #(32) RF (~clk, rst , MEM_WB_Ctrl[1], IF_ID_Inst [`IR_rs1], IF_ID_Inst [`IR_rs2], MEM_WB_Rd, WriteData, ReadData1, ReadData2);
    rv32_ImmGen IG (IF_ID_Inst, gen_out);
    n_bit_register #(288) ID_EX_REG (
    {IF_ID_PC, {{27{1'b0}},IF_ID_Inst[`IR_rd]}, 
    flush_pipeline ? {32{1'b0}} : {ALUSrc, ALUOp, {21{1'b0}}, Jump, WhichReg, MemRead, MemWrite, RegWrite, Branch},
     ReadData1, ReadData2, 
    {{27{1'b0}},IF_ID_Inst[`IR_rs1]},
    {{27{1'b0}},IF_ID_Inst[`IR_rs2]},
    {IF_ID_Inst[30], IF_ID_Inst[3], {27{1'b0}}, IF_ID_Inst[`IR_funct3]}, 
     gen_out}, 
     rst, 1'b1, clk, 
    {ID_EX_PC, ID_EX_Rd, ID_EX_Ctrl, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Rs1, ID_EX_Rs2, ID_EX_Func, ID_EX_Imm});

    //////////////////////////// end of decoding stage //////////////////////////////////////////////////////
    
    wire [31:0] EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_RegR1, ALUInput1, ALUInput2;
    wire [31:0] EX_MEM_Imm;
    wire [31:0] EX_MEM_Rd, EX_MEM_PC;
    wire [3:0]  EX_MEM_Flags; 
    wire forwardA, forwardB;
    
    assign JALAddress = ID_EX_PC + ID_EX_Imm;
    assign JALRAddress = ID_EX_PC + ID_EX_RegR1 + ID_EX_Imm;
    assign BranchAddress = ID_EX_PC + ID_EX_Imm;
    assign ALUInput1 = (forwardA) ? WriteData : ID_EX_RegR1;
    assign ALUInput2 = (forwardB) ? WriteData : ID_EX_RegR2;
    assign MUX_ALU = (ID_EX_Ctrl[31])? ID_EX_Imm : ALUInput2;

    ALU_ControlUnit ACU (ID_EX_Func[31], ID_EX_Ctrl [30 : 29], ID_EX_Func [2:0], ALU_Sel);
    prv32_ALU ALU(ALUInput1, MUX_ALU, ALUResult, zf, cf, vf, sf, ALU_Sel);
    
    n_bit_register #(356) EX_MEM (
    {ID_EX_RegR1, ID_EX_Func, ID_EX_Imm, ID_EX_PC,
    {zf, cf, vf, sf}, ID_EX_Ctrl, 
     BranchAddress, JALAddress, JALRAddress, ALUResult, 
     ALUInput2, ID_EX_Rd}, 
     rst, 1'b1, ~clk,
    {EX_MEM_RegR1, EX_MEM_Func, EX_MEM_Imm, EX_MEM_PC, EX_MEM_Flags, EX_MEM_Ctrl, EX_MEM_PC_Branch, 
     EX_MEM_PC_JAL, EX_MEM_PC_JALR, EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_Rd});
    
    /////////////////////////// end of execution stage /////////////////////////////////////////////////////
    
    wire [31:0] MEM_WB_Mem_out, MEM_WB_ALU_out;
    wire [31:0] MEM_WB_Imm, MEM_WB_PC; 

    Forwarding_Unit FWD (forwardA, forwardB, ID_EX_Rs1, ID_EX_Rs2, MEM_WB_Rd, MEM_WB_Ctrl[1]);
    Branch_CU BU(EX_MEM_Func[2:0], EX_MEM_Flags[3], EX_MEM_Flags[2], EX_MEM_Flags[1], EX_MEM_Flags[0], Branchflag);  
    IDM MEM(clk, EX_MEM_Ctrl[3], EX_MEM_Ctrl[2], {EX_MEM_ALU_out[7:0] , PC}, EX_MEM_Func[2:0],EX_MEM_RegR2, ReadData);  
    
    assign flush_pipeline =  EX_MEM_Ctrl[0] & Branchflag;
    
     n_bit_register #(192) MEM_WB(
     {EX_MEM_Imm, EX_MEM_Ctrl, EX_MEM_ALU_out, EX_MEM_Rd, ReadData, EX_MEM_PC}, 
      rst, 1'b1, clk, 
     {MEM_WB_Imm, MEM_WB_Ctrl, MEM_WB_ALU_out, MEM_WB_Rd, MEM_WB_Mem_out, MEM_WB_PC});

    /////////////////////////// end of memory stage ///////////////////////////////////////////////////////
    
    always @(*) begin
        case(MEM_WB_Ctrl[6:4]) 
            3'b000:  WriteData = MEM_WB_ALU_out;
            3'b001:  WriteData = MEM_WB_Mem_out;
            3'b010:  WriteData = MEM_WB_PC+4;
            3'b011:  WriteData = MEM_WB_Imm;
            3'b100:  WriteData = MEM_WB_PC + MEM_WB_Imm;
            default: WriteData = 0;
        endcase
    end   
endmodule