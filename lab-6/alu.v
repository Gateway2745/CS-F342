module mux2to1(out,sel,in1,in2);
input in1,in2,sel;
output out;
wire not_sel,a1,a2;
not (not_sel,sel);
and (a1,sel,in2); 
and (a2,not_sel,in1);
or(out,a1,a2);
endmodule

module bit8_2to1mux(out,sel,in1,in2);
input [7:0] in1,in2;
output [7:0] out;
input sel;
genvar j;
generate for (j=0; j<8;j=j+1) begin: mux_loop
mux2to1 m1(out[j],sel,in1[j],in2[j]);
end
endgenerate
endmodule

module bit4_8to1mux(output [31:0] out, input sel, input [31:0] A, input[31:0] B);
wire [7:0] tmp;
genvar i;
generate for (i=1; i<=4;i=i+1) begin: mux_loop
bit8_2to1mux m1(out[8*i-1:8*(i-1)],sel,A[8*i-1:8*(i-1)],B[8*i-1:8*(i-1)]);
end
endgenerate
endmodule


module bit32AND (out,in1,in2);
input [31:0] in1,in2;
output [31:0] out;
assign {out}=in1 &in2;
endmodule

module bit32OR (out,in1,in2);
input [31:0] in1,in2;
output [31:0] out;
assign {out}=in1 | in2;
endmodule

module Adder_dataflow (Cout, Sum,In1,In2,Cin);
input [31:0] In1;
input [31:0] In2;
input Cin;
output Cout;
output [31:0] Sum;
assign {Cout,Sum}=In1+In2+Cin;
endmodule


module ALU(output cout, output [31:0] result, input [31:0] A, input [31:0] B, input binv, input cin, input [1:0] op);

wire [31:0] out[0:3];
wire [1:0] cf;
bit32AND band(out[0],A,B);
bit32OR bor(out[1],A,B);
Adder_dataflow sum(cf[0],out[2],A,B,1'b0);
Adder_dataflow diff(cf[1],out[3],A,~B,1'b1);

assign result = op==2'b00 ? out[0]:
                op==2'b01 ? out[1]:
                op==2'b10 ? 
                binv==1'b0 ? out[2]:
                out[3]:
                0;

assign cout = op==2'b10 ?
              binv==1'b0 ? cf[0]:
              cf[1] :
              0;
endmodule

module ControlUnit(RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite,Branch,ALUOp1,ALUOp2,Op);
input [5:0] Op;
output RegDst,ALUSrc,MemtoReg, RegWrite, MemRead, MemWrite,Branch,ALUOp1,ALUOp2;
wire Rformat, lw,sw,beq;
assign Rformat= (~Op[0])& (~Op[1])& (~Op[2])& (~Op[3])&(~Op[4])& (~Op[5]);
assign lw = (Op[0])& (Op[1])& (~Op[2])& (~Op[3])&(~Op[4])& (Op[5]);
assign sw = (Op[0])& (Op[1])& (~Op[2])& (Op[3])&(~Op[4])& (Op[5]);
assign beq = (~Op[0])& (~Op[1])& (Op[2])& (~Op[3])&(~Op[4])& (~Op[5]);

assign RegDst = Rformat;
assign ALUSrc = lw | sw;
assign MemtoReg = lw;
assign RegWrite = Rformat | lw;
assign MemRead = lw;
assign MemWrite = lw;
assign Branch = beq;
assign ALUOp1 = Rformat;
assign ALUOp2 = beq;
endmodule

module ALUcontrol(output [2:0] out, input [1:0] op, input [5:0] funct);
assign out[0] = (funct[0] | funct[3]) & op[1];
assign out[1] = (~funct[2] | ~op[1]);
assign out[2] = (funct[1] & op[1]) | op[0];
endmodule
