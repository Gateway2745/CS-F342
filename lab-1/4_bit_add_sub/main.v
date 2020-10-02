// select = 0 => add else subtract
module bit_add_sub(output reg result, output reg dout, input A, input B, input din, input select);
always @(A or B or din or select)
begin
    if(select==0)
    begin
        result = A + B + din;
        dout = (A & B) || (A ^ B) & din;
    end
    else
    begin
        result = A - B - din;
        dout = (~A & B) || ~(A ^ B) & din;
    end
end
endmodule

module four_bit_add_sub(output [3:0] result, output dout, input [3:0]A, input [3:0]B, input din, input select);
wire w[3:0];
assign dout = w[3];
bit_add_sub ba0(result[0],w[0],A[0],B[0],din,select);
bit_add_sub ba1(result[1],w[1],A[1],B[1],w[0],select);
bit_add_sub ba2(result[2],w[2],A[2],B[2],w[1],select);
bit_add_sub ba3(result[3],w[3],A[3],B[3],w[2],select);
endmodule

// testbench
module bit_add_sub_tb;
wire [3:0] result;
wire dout;
reg [3:0] A;
reg [3:0] B;
reg din;
reg select;
four_bit_add_sub ba(result,dout,A,B,din,select);
integer i,j,k;

initial
begin
    A=0;
    B=0;
    din=0;
    select=0;
end

initial
begin
for(i=0;i<=15;i=i+1)
begin
    for(j=0;j<=15;j=B+1)
    begin
        for(k=0;k<=1;k=k+1)
        begin
            #5 A=i;B=j;din=k; 
        end
    end
select = i%2;
end
end
initial
$monitor($time," A=%b,B=%b,din=%b,result=%b,dout=%b,select=%b",A,B,din,result,dout,select);
endmodule