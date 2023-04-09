`timescale 1ns / 1ps

module r32_CPU_tb();
    reg clk, rst; 

    rv32_CPU UUT (clk, rst); 
    initial begin
        clk = 0;
        rst = 1;
        #100
        rst = 0;
        forever begin 
            clk = ~clk;
            #100;
        end
    end
endmodule
