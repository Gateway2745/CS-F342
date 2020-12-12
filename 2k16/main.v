module BHT(output reg [1:0] D, input [9:0] A, input [1:0] I, input WR);
reg [1023:0][1:0] mem;
integer i;
initial
    for(i=0;i<=1023;i=i+1) mem[i]=2'b00;
always @(A or I or WR)
begin
    if(WR)
        mem[A] <= I;
    D <= mem[A]; 
end
endmodule

module MUX1(output [1:0] O, input [1:0] in1, input [1:0] in0, input S);
assign O = S==0 ? in0:in1;
endmodule

module PREDICTOR(output reg [1:0] N, input X);

reg [1:0] curr_state;
initial
    curr_state = 2'b00;
always @(X)
begin
    if(X)
    begin
        case(curr_state)
        2'b00 : N=2'b01;
        2'b01 : N=2'b11;
        2'b10 : N=2'b11;
        2'b11 : N=2'b11;
        endcase
    end
    else
    begin
        case(curr_state)
        2'b00 : N=2'b00;
        2'b01 : N=2'b00;
        2'b10 : N=2'b00;
        2'b11 : N=2'b10;
        endcase
    end
    curr_state = N;
end
endmodule

module INTG(output reg predn ,input [9:0] addr, input X);

initial 
begin
    predn = 1'b0;
    wr1=1'b0;
    wr2=1'b0;
end

wire [1:0] next_state;
PREDICTOR p(next_state,X);

wire [1:0] o1;
wire wr1;
BHT t1(o1,addr,next_state,wr1);

wire [1:0] o2;
wire wr2;
BHT t2(o2,addr,next_state,wr2);

wire [1:0] curr_state;
MUX1 mux1(curr_state, o1, o2, predn);

always @(curr_state)
begin
    case(curr_state)
    2'b00 : 
    begin
        predn = 1'b0;
        wr1 = 1'b1;
    end
    2'b01 : 
    begin
        predn = 1'b0;
        wr1 = 1'b1;
    end
    2'b10 : 
    begin
        predn = 1'b1;
        wr2=1'b1;
    end
    2'b11 : 
    begin
        predn = 1'b1;
        wr2=1'b1;
    end
end


endmodule

module tb;

wire [1:0] out;
reg [9:0] addr;
reg X;

INTG intg(out ,addr, X);

initial
begin
    addr = 10'b0011110000;
    #2 X=0;
    $display("time = %0d , output = %b",$time,out);
    #2 X=1;
    $display("time = %0d , output = %b",$time,out);
    #2 X=1;
    #2 X=1;
    #2 X=0;
    $finish;
end

// always 
//     #2 $display("time = %0d , output = %b",$time,out);
endmodule