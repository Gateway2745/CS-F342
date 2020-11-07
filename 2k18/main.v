`timescale 1ms/1ns

module d_ff(output reg q, input d, input clk, input set, input reset);
always @(posedge clk)
    case({set,reset})
    2'b00 : q <= d;
    2'b01 : q <= 1'b0;
    2'b10 : q <= 1'b1;
    2'b11 : q <= 1'bz;
    endcase
endmodule

module ControlLogic(output [2:0] T, input S, input Z, input X, input clk, input setT0, input resetT1, input resetT2);
wire s_bar,t1,t2,out1;
not(s_bar,S);
and(t1,T[0],s_bar);
and(t2,T[2],Z);
or(out1,t1,t2);
d_ff d1(T[0],out1,clk,setT0,1'b0);

wire x_bar,z_bar,q1,q2,q3,out2;
and(q1,T[0],S);
not(x_bar,X);
not(z_bar,Z);
and(q2,T[2],x_bar,z_bar);
and(q3,T[1],x_bar);
or(out2,q1,q2,q3);
d_ff d2(T[1],out2,clk,1'b0,resetT1);

wire s1,s2,out3;
and(s1,T[1],X);
and(s2,T[2],z_bar,X);
or(out3,s1,s2);
d_ff d3(T[2],out3,clk,1'b0,resetT2);

endmodule


module TFF(output reg q, input t, input clk, input clear);
initial
    q <= 0;
always @(posedge clk)
begin
    if(clear)
        q <= 0;
    else
    begin
        if(t) q <= ~q;
        else q <= q;
    end 
end
endmodule

module COUNTER_4BIT(output [3:0] q, input clk, input clear, input enable);
wire clock;
assign clock = clk * enable;
TFF t1(q[0], 1'b1, clock, clear);
TFF t2(q[1], q[0], clock, clear);

wire tmp1;
and(tmp1, q[0],q[1]);
TFF t3(q[2], tmp1, clock, clear);

wire tmp2;
and(tmp2, tmp1, q[2]);
TFF t4(q[3], tmp2, clock, clear);
endmodule


module INTG(output [3:0] ctr, output G, input S, input X, input clk, input setT0, input resetT1, input resetT2);

wire [2:0] T;
wire w1,w2,Z,enable,clear;

assign Z = ctr[0] & ctr[1] & ctr[2] & ctr[3];
assign w1 = T[1] & X;
assign w2 = T[2] & ~Z & X;
assign enable = w1 | w2;
assign clear = T[0] & S;

ControlLogic cl(T, S, Z, X, clk,setT0,resetT1,resetT2);

COUNTER_4BIT counter(ctr, clk, clear, enable);

wire w3;
assign w3 = Z & T[2];
d_ff dff(G, w3, clk,1'b0,1'b0);

endmodule

module tb;
wire [3:0] ctr;
wire G;
reg S,X,clk,setT0,resetT1,resetT2;
INTG intg(ctr, G, S, X, clk,setT0,resetT1,resetT2);

initial 
begin
    // $monitor("time : %0d , clk : %b , S = %b , X = %b , counter : %b , output = %b, state = %b , Z = %b, enable = %b",$time,clk,S,X,ctr,G,intg.T,intg.Z,intg.enable);
    $monitor("time : %0d , S = %b , X = %b , counter : %b , output = %b",$time,S,X,ctr,G);
    S=1;
    X=1;
    clk=0;
    #0.1 setT0=1'b1;resetT1=1'b1;resetT2=1'b1;
    #0.5 setT0=0;resetT1=0;resetT2=0;
    #20 $finish;
end

always
    #0.5 clk = ~clk;

endmodule