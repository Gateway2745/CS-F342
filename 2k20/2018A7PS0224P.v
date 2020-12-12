// Name : Rohit R
// ID   : 2018A7PS0224P

`timescale 1ms/1ns

module RSFF(output reg Q, output reg Qbar, input S, input R, input clk, input reset);
always @(reset) // asynchronous reset
    if(reset) 
    begin
        Q <= 0;
        Qbar <=1;
    end
always@(posedge clk)
begin
    if(!reset)
    begin
        if(S == 1)
        begin
            Q <= 1;
            Qbar <= 0;
        end
        else if(R == 1)
        begin
            Q <= 0;
            Qbar <= 1;
        end
        else if(S == 0 & R == 0)
        begin
            Q <= Q;
            Qbar <= Qbar;
        end
    end
end
endmodule


module DFF(output Q, output Qbar, input D, input clk, input reset);
wire S,R;
assign S = D;
assign R = ~D;
RSFF rsff(Q, Qbar, S, R, clk,reset);
endmodule

module Ripple_Counter(output [3:0] q, input clk, input reset);
wire [3:0] q_bar;
DFF d1(q[0], q_bar[0], q_bar[0], clk, reset);
DFF d2(q[1], q_bar[1], q_bar[1], q_bar[0], reset);
DFF d3(q[2], q_bar[2], q_bar[2], q_bar[1], reset);
DFF d4(q[3], q_bar[3], q_bar[3], q_bar[2], reset);
endmodule

module MEM1(output reg [8:0] out, input [2:0] in);
reg [7:0][8:0] mem;
always @(in)
    out = mem[in];

initial
begin
    mem[0] = 9'b000111111;
    mem[1] = 9'b001100011;
    mem[2] = 9'b010100111;
    mem[3] = 9'b011101011;
    mem[4] = 9'b100101111;
    mem[5] = 9'b101110011;
    mem[6] = 9'b110110111;
    mem[7] = 9'b111111011;
end
endmodule

module MEM2(output reg [8:0] out, input [2:0] in);
reg [7:0][8:0] mem;
always @(in)
    out = mem[in];

initial
begin
    mem[0] = 9'b000000000;
    mem[1] = 9'b001000100;
    mem[2] = 9'b010001000;
    mem[3] = 9'b011001100;
    mem[4] = 9'b100010000;
    mem[5] = 9'b101010100;
    mem[6] = 9'b110011000;
    mem[7] = 9'b111011100;
end
endmodule


module MUX2To1(output q,input in1, input in2, input sel);
assign q = sel==0 ? in1 : in2;
endmodule

module MUX16To8(output [7:0] q, input [7:0] in1, input [7:0] in2, input sel);
genvar i;
generate
for(i=0;i<8;i=i+1)
begin
    MUX2To1 mux21(q[i], in1[i],in2[i],sel);
end
endgenerate
endmodule

module Fetch_Data(output [7:0] data, output parity, input [3:0] ctr);
wire [7:0] data1,data2;
wire parity1,parity2;
wire [2:0] sel;
assign sel = {ctr[2],ctr[1],ctr[0]};

MEM1 mem1({data1,parity1},sel);
MEM2 mem2({data2,parity2},sel);

MUX16To8 mux168(data,data1,data2,ctr[3]);
MUX2To1 mux21(parity,parity1,parity2,ctr[3]);
endmodule

module Parity_Checker(output outp, input [7:0] data, input inp);
wire t;
assign t = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7];
assign outp = t==inp ? 1 : 0;
endmodule

module Design(output result, input clk, input reset);

wire [3:0] rcout;
Ripple_Counter rpc(rcout, clk, reset);

wire [7:0] data;
wire parity;
Fetch_Data fdata(data, parity, rcout);

Parity_Checker pc(result, data, parity);
endmodule

module TestBench;
reg clk,reset;
wire result;
Design d(result, clk,reset);

initial
begin
    clk=0;
    reset=1;
    #0.1 reset=0;
    $display("time = %0d , clk = %b , reset = %b , match = %b, counter = %b",$time,clk,reset,result, d.rcout);
    #20 $finish;
end

always
    #1 $display("time = %0d , clk = %b , reset = %b , match = %b, counter = %b ",$time,clk,reset,result, d.rcout);

always 
    #0.5 clk = ~clk;

endmodule