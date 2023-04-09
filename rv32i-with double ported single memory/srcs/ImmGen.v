`timescale 1ns / 1ps

module ImmGen(input [31:0] inst, output reg [31:0] gen_out);

always@(*) begin
	if(inst[6:5] == 2'b00)  begin	//I-type
		gen_out[11:0] = inst[31:20];
		gen_out[31:12] = (inst[31] == 1'b0)?20'b00000000000000000000:20'b11111111111111111111;
 	end
	
	else if(inst[6:5] == 2'b01)  begin	//S-type
		gen_out[11:0] = {inst[31:25], inst[11:7]};
		gen_out[31:12] = (inst[31] == 1'b0)?20'b00000000000000000000:20'b11111111111111111111;
	end
	else if(inst[6] == 1'b1) begin //SB-type
		gen_out[11:0] = {inst[31], inst[7], inst[30:25], inst[11:8]};
		gen_out[31:13] = (inst[31] == 1'b0)?20'b00000000000000000000:20'b11111111111111111111;
	end
end
endmodule