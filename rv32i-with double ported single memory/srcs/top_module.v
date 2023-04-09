`timescale 1ns / 1ps

module CPU_Pipelined(input clk, input clk_BCD, input rst, input [1:0] ledSel, input [3:0] bcdSel, output reg [15:0] LEDOut, 
  //output reg [12:0] BCDOut);
output [3:0] Anode,    output [6:0] Cathode );
    reg [12:0] BCDOut;
    
    reg [31:0] PC;
    wire [1:0] ALUOp;
    wire [31:0] gen_out, WriteData, ReadData1, ReadData2, ReadData, PC_NEXT, decoded_inst, IF_ID_PC, IF_ID_Inst, PC_PLUS_4, ShiftLeftOut, PC_SUM;
    wire Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, zeroFlag;
    wire [31:0] EX_MEM_BranchAddOut, EX_MEM_ALU_out, EX_MEM_RegR2;
    wire stall;

    always@(posedge clk or posedge rst) begin
        if(stall) PC = PC;
        else if (rst) PC = 0;
        else PC = PC_NEXT;
    end
    
    assign PC_PLUS_4 = 4 + PC;
    assign PC_NEXT = (Branch) ? EX_MEM_BranchAddOut : PC_PLUS_4;  
         
    n_bit_register #(64) IF_ID_REG (stall, {decoded_inst, {PC}}, rst, 1'b1, clk, {IF_ID_Inst, IF_ID_PC});
    
    /* END OF FETCH STAGE */
    
    wire [31:0] ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm;
    wire [31:0] ID_EX_Ctrl;
    wire [31:0] ID_EX_Func;
    wire [31:0] ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd; 
    wire Branch_CU;
    Control_Unit CU (IF_ID_Inst[6:2], Branch_CU, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp);
    registerFile #(32) RF (~clk, rst , MEM_WB_Ctrl[1], IF_ID_Inst[19:15], IF_ID_Inst[24:20], MEM_WB_Rd[4:0],
     WriteData, ReadData1, ReadData2);
    ImmGen IG (IF_ID_Inst, gen_out);    
    n_bit_register #(288) ID_EX_REG (1'b0, {IF_ID_PC, {{27{1'b0}},IF_ID_Inst[11:7]}, (stall == 1'b1) ? {32{1'b0}} : {ALUSrc, ALUOp, 
    {24{1'b0}}, MemtoReg, MemRead, MemWrite, RegWrite, Branch_CU}, ReadData1, ReadData2, 
    {{27{1'b0}},IF_ID_Inst[19:15]}, {{27{1'b0}},IF_ID_Inst[24:20]},
     {IF_ID_Inst[30],{28{1'b0}}, IF_ID_Inst[14:12]}, gen_out}, rst, 1'b1, clk, 
     {ID_EX_PC, ID_EX_Rd, ID_EX_Ctrl, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Rs1, ID_EX_Rs2, ID_EX_Func, ID_EX_Imm});

    /* END OF DECODING STAGE */
 
    
    wire [31:0] EX_MEM_Ctrl;
    wire [31:0] EX_MEM_Rd;
    wire [3:0] ALU_Sel;
    wire EX_MEM_Zero; 
    wire [31:0] MUX_ALU ,ALUResult;
    wire [1:0]  forwardA, forwardB;
    wire [31:0] ALU_Input1, ALU_Input2;
    n_bit_ShiftLeft #(32) SL (ID_EX_Imm, ShiftLeftOut);
    assign PC_SUM = ID_EX_PC + ShiftLeftOut;  
    assign MUX_ALU = (ID_EX_Ctrl[31])? ID_EX_Imm : ALU_Input2;

    ALU_ControlUnit ACU (ID_EX_Func[31], ID_EX_Ctrl[30:29], ID_EX_Func[2:0], ALU_Sel);
    
    MUX_4X1 ALU1 (ID_EX_RegR1, WriteData, EX_MEM_ALU_out, 0, forwardA, ALU_Input1);
    MUX_4X1 ALU2 (ID_EX_RegR2, WriteData, EX_MEM_ALU_out, 0, forwardB, ALU_Input2);

    N_bit_ALU #(32) NALU (ALU_Input1, MUX_ALU, ALU_Sel, zeroFlag, ALUResult);  
    n_bit_register #(161) EX_MEM (1'b0, {zeroFlag, ID_EX_Ctrl, PC_SUM, ALUResult, 
    ALU_Input2, ID_EX_Rd}, rst, 1'b1, clk, {EX_MEM_Zero, EX_MEM_Ctrl, EX_MEM_BranchAddOut, 
    EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_Rd});   

    /* END OF EXECUTION STAGE */
    
    wire [31:0] MEM_WB_Mem_out, MEM_WB_ALU_out;
    wire [31:0] MEM_WB_Ctrl;
    wire [31:0] MEM_WB_Rd; 
    assign Branch = EX_MEM_Zero & EX_MEM_Ctrl[0];
    rv32_IDM MEM(clk, EX_MEM_Ctrl[3], EX_MEM_Ctrl[2], {EX_MEM_ALU_out[7:0] , PC}, EX_MEM_Func[2:0],EX_MEM_RegR2, ReadData);  
    
    n_bit_register #(128) MEM_WB(1'b0, {EX_MEM_Ctrl, ReadData, EX_MEM_ALU_out, EX_MEM_Rd}, rst, 1'b1, clk, 
    {MEM_WB_Ctrl, MEM_WB_Mem_out, MEM_WB_ALU_out, MEM_WB_Rd});
    
    /* END OF MEMORY STAGE */
    Forwarding_Unit FU(
        forwardA, forwardB, 
        ID_EX_Rs1, ID_EX_Rs2,
        EX_MEM_Rd, MEM_WB_Rd, 
        EX_MEM_Ctrl[1], MEM_WB_Ctrl[1] 
    );  
    
    Hazard_Detection HD(stall, IF_ID_Inst[19:15], IF_ID_Inst[24:20], ID_EX_Rd, ID_EX_Ctrl[3]);

    assign WriteData = (MEM_WB_Ctrl[4]) ? MEM_WB_Mem_out : MEM_WB_ALU_out;


    always @(*) begin
        case (ledSel) 
            0: LEDOut = decoded_inst[15:0];
            1: LEDOut = decoded_inst[31:16];
            2: LEDOut = {8'b00000000, ALUOp, ALU_Sel, zeroFlag, zeroFlag & Branch}; 
            default: LEDOut = 0;
        endcase
    end
    always @(*) begin
        case (bcdSel) 
            0: BCDOut = PC;
            1: BCDOut = PC + 4;
            2: BCDOut = Branch;
            3: BCDOut = (zeroFlag & Branch) ? PC + (gen_out >> 1) : PC + 4;
            4: BCDOut = ReadData1;
            5: BCDOut = ReadData2;
            6: BCDOut = WriteData;
            7: BCDOut = gen_out;
            8: BCDOut = gen_out >> 1;
            9: BCDOut = ALUSrc ? gen_out : ReadData2;
            10: BCDOut = ALUResult;
            11: BCDOut = ReadData;
        endcase
    end
   Four_Digit_Seven_Segment_Driver BCD (clk_BCD, BCDOut, Anode, Cathode);
endmodule
