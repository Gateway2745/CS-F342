`timescale 1ms/1ns

module MUX_SMALL(output q, input [1:0] in, input sel);
assign q = sel == 0 ? in[0] : in[1];
endmodule

module MUX_BIG(output q, input [7:0] in, input [2:0] sel);
wire [3:0] t1;
genvar i;
generate for(i=0;i<4;i=i+1)
begin
    MUX_SMALL ms(t1[i],{in[2*i+1],in[2*i]},sel[0]);
end
endgenerate

wire [1:0] t2;
generate for(i=0;i<2;i=i+1)
begin
    MUX_SMALL ms2(t2[i],{t1[2*i+1],t1[2*i]},sel[1]);
end
endgenerate

MUX_SMALL ms3(q,{t2[1],t2[0]},sel[2]);
endmodule

module TFF(output reg q, input t, input clk, input clear); // asynchronous clear
always @(clear)
    if(clear) q <= 0;

always @(posedge clk)
begin
    if(!clear)
    begin
        if(t) q <= ~q;
        else q <= q;
    end
end
endmodule

module COUNTER_4BIT(output [3:0] q, input clk, input clear);
TFF t1(q[0], 1'b1, clk, clear);
TFF t2(q[1],q[0],clk,clear);

wire w1;
assign w1 = q[1] & q[0];
TFF t3(q[2],w1,clk,clear);

wire w2;
assign w2 = q[2] & w1;
TFF t4(q[3],w2,clk,clear);
endmodule

module COUNTER_3BIT(output [2:0] q, input clk, input clear);
TFF t1(q[0], 1'b1, clk, clear);
TFF t2(q[1],q[0],clk,clear);

wire w1;
assign w1 = q[1] & q[0];
TFF t3(q[2],w1,clk,clear);
endmodule

module MEMORY(output reg [7:0] q, input [3:0] in);
reg [15:0][7:0] mem;
integer i;

initial
begin
    for(i=0;i<16;i=i+1)
    begin
        if(i%2==0) mem[i] = 8'hcc;
        else mem[i] = 8'haa;
    end
end

always @(in)
    q = mem[in];

endmodule

module INTG(output q, input clk, input clear);

wire [2:0] c3out;
COUNTER_3BIT c3(c3out, clk, clear);

wire c4clk;
assign c4clk = c3out[0] & c3out[1] & c3out[2];

wire [3:0] c4out;
COUNTER_4BIT c4(c4out, c4clk, clear);

wire [7:0] mem_out;
MEMORY mem(mem_out, c4out);

MUX_BIG mux81(q, mem_out, c3out);
endmodule


module tb;
reg clk,clear;
wire q;
INTG intg(q, clk, clear);

initial
begin
    clk = 0;
    clear=1;
    #0.1 clear=0;
    //$monitor("time : %0d , c3out = %b , memout = %b , output = %b ", $time, intg.c3out, intg.mem_out , q);
    //$monitor("time : %0d , output = %b ", $time, q);
    #20 $finish;
end

always
    #1 $display("time : %0d , output = %b ", $time, q);

always
    #0.5 clk = ~ clk;

endmodule