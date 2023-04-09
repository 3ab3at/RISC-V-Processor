`timescale 1ns / 1ps

module IDM_tb();
    reg        clk, MemRead, MemWrite;
    reg [31:0]  addr_read;//, addr_write;
    reg [2:0]  func;
    reg [31:0] data_in;
    wire [31:0] data_out;

    IDM UUT (clk, MemRead, MemWrite, addr_read, func, data_in, data_out); 
    initial begin
        clk = 0;
        forever begin 
            #100
            clk = ~clk;
        end
    end
    
    initial begin 
        func = 3'b010; addr_read = 32'd8; MemRead = 0; MemWrite = 0;
        #200
        addr_read = 32'd4; MemRead = 1'b1;
        #200
        MemRead = 0; data_in = 32'd17; MemWrite = 1;
        #200
        addr_read = 32'd4; MemRead = 0; MemWrite = 0; 
        #200
        addr_read = 32'd0; func = 3'b000; MemRead = 1; MemWrite = 0;
    end
endmodule
