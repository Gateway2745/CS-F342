`timescale 1ms/1ns

module encoder(output reg [2:0] q, input [7:0] in);
always @(in)
    case(in)
    8'd1 : q = 3'b000;
    8'd2 : q = 3'b001;
    8'd4 : q = 3'b010;
    8'd8 : q = 3'b011;
    8'd16 : q = 3'b100;
    8'd32 : q = 3'b101;
    8'd64 : q = 3'b110;
    8'd128 : q = 3'b111;
    endcase
endmodule

module ALU(output [3:0] q, input [3:0] A, input [3:0] B, input [2:0] opcode);
assign q = opcode == 3'b000 ? A + B : 
           opcode == 3'b001 ? A - B :
           opcode == 3'b010 ? A ^ B :
           opcode == 3'b011 ? A | B : 
           opcode == 3'b100 ? A & B :
           opcode == 3'b101 ? ~(A | B) :
           opcode == 3'b110 ? ~(A & B) :
           opcode == 3'b111 ? ~(A ^ B) :
           4'bz;
endmodule

module EPR(output q, input [3:0] in);
assign q = in[0] ^ in[1] ^ in[2] ^ in[3];
endmodule

module pipeline1(output reg [2:0] ctrl, output reg [3:0] regA, output reg [3:0] regB, input [7:0] fncode, input [3:0] A, input [3:0] B, input clk);
wire [2:0] q;
encoder enc(q,fncode);
always @(posedge clk)
begin
    regA = A;
    regB = B;
    ctrl = q;
end
endmodule

module pipeline2(output reg [3:0] regR, input [3:0] A, input [3:0] B, input [2:0] ctrl, input clk);
wire [3:0] q;
ALU alu(q,A,B,ctrl);
always @(clk)
begin
    regR = q;
end
endmodule

module INTG(output q, input [3:0] A, input [3:0] B, input [7:0] fncode, input clk);
wire [2:0] ctrl;
wire [3:0] wa,wb;
pipeline1 p1(ctrl, wa, wb, fncode,A,B,clk);

wire [3:0] wout;
pipeline2 p2(wout, wa, wb, ctrl, clk);

EPR epr(q,wout);
endmodule

module tb;
reg [3:0] A,B;
reg [7:0] fncode;
reg clk;
wire q;

INTG intg(q, A, B, fncode, clk);

initial
begin
    A = 8'd5;
    B = 8'd6;
    clk = 0;
    fncode = 8'd1;
    #1 A=2; B=3;fncode=8'd2;
    #1 A = 12; B=5;fncode=8'd2;
    #15 $finish;
end

always
    #1 $display("time = %0d , regCtrl = %b , regR = %b , output = %b",$time, intg.p1.ctrl,intg.p2.regR, q);
always 
    #0.5 clk = ~clk;
endmodule