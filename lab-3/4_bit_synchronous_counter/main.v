`timescale 1ms/1ns

module jk_ff(output reg q, input j, input k, input clk, input reset);
always @(posedge clk or posedge reset)
begin
    if(reset) q <= 0;
    else if(j==1 && k==0) q=1;
    else if(j==0 && k==1) q=0;
    else if(j==1 && k==1) q=~q;
end
endmodule

module counter(output [3:0]q, input clk, input reset);
wire w[0:1];
and(w[0],q[0],q[1]);
and(w[1],w[0],q[2]);
jk_ff f1(q[0],1'b1,1'b1,clk,reset);
jk_ff f2(q[1],q[0],q[0],clk,reset);
jk_ff f3(q[2],w[0],w[0],clk,reset);
jk_ff f4(q[3],w[1],w[1],clk,reset);
endmodule

module testbench;
wire [3:0] q;
reg clk,reset;
counter c(q,clk,reset);

initial
begin
    $monitor($time, " q=%b", q);
    clk=0;
    reset=1;
    #0.2 reset=0;
    #16 $finish;
end
always
    #0.5 clk=~clk;
endmodule
