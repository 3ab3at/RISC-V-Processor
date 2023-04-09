`timescale 1ns / 1ps

module FA(input A, input B, input Cin, output S, output Cout);

assign S = A ^ B ^ Cin;
assign Cout = ((A ^ B) & Cin) | (A & B);

endmodule

module RCA #(parameter n = 8) (input[n-1:0] A, input[n-1:0] B, input cin, output [n:0] S);

wire[n:0] c;

assign c[0] = 0;
genvar i;

wire[n-1:0] G;
assign G = (cin == 0)?B:~B+1;

generate
	for(i = 0; i < n; i = i + 1) begin: myblockname
		FA myFA(A[i], G[i], c[i], S[i], c[i+1]);
	end
endgenerate
assign S[n] = c[n];
   
endmodule

module  N_bit_ALU #(parameter n = 32) (input [n-1:0] A, B, [3:0] sel, output Z, reg [n-1:0] C);

reg cin;
wire [31:0]sum;

RCA #(32) re ( A, B, cin, sum);


always@(*)
begin
    case (sel)
        4'b0010: begin
        cin = 0;
        C = sum;
        end
        4'b0110: begin
        cin = 1;
        C = sum;
        end
        4'b0000: begin
        C = A&B;
        end
        4'b0001: begin
        C = A|B;
        end
        default: begin
        C = 0;
        end
    endcase
end

assign Z = (C==0) ? 1'b1 : 1'b0;

endmodule
