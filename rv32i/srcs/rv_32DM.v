`timescale 1ns / 1ps

module IDM_new(
    input  wire        clk, MemRead, MemWrite, 
    input  wire [31:0] addr_read, 
    input  wire [31:0] addr_write, 
    input  wire [02:0] func,
    input  wire [31:0] data_in, 
    output wire [31:0] data_out
);
    reg [31:0] IM [0:63];
    reg [31:0] DM [0:63];
    reg [31:0] data;
    
    wire [31:0] next_inst;
   
    assign next_inst = IM[addr_read >> 2];
    
    reg [31:0] real_addr;

    always @(func, MemRead, MemWrite) begin
        real_addr = (MemRead)? addr_read : addr_write;
        case(func) 
            3'b000:  real_addr = real_addr; // LB
            3'b001:  real_addr = (real_addr >> 1); // LH
            3'b010:  real_addr = (real_addr >> 2); // LW
            3'b100:  real_addr = real_addr; //LBU
            3'b101:  real_addr = (real_addr >> 1); //LHU
            default: real_addr = real_addr;
        endcase
    end

    always@(negedge clk) begin
        if(MemWrite)
            DM[real_addr] = data_in;
        else data = data;
    end

    always @(*) begin
        if (MemRead) begin
            case(func)
                3'b000: data = {{24{DM[real_addr][7]}},{DM[real_addr][7:0]}};
                3'b001: data = {{16{DM[real_addr][15]}},{DM[real_addr][15:0]}};
                3'b010: data = DM[real_addr];
                3'b100: data = {{24{1'b0}},{DM[real_addr][7:0]}};
                3'b101: data = {{16{1'b0}},{DM[real_addr][15:0]}};
            endcase
        end
        else data = data;
    end
    
    assign data_out = (MemRead | MemWrite) ? data : next_inst;
    
    initial begin 
        DM[0]=32'd2555;
        DM[1]=32'd9;
        DM[2]=32'd25;
    end
    
    initial begin
        IM[0] = 32'd225;
        IM[1] = 32'd226;
        IM[2] = 32'd227;
        IM[3] = 32'd228;
        IM[4] = 32'd229; 
    end
endmodule
