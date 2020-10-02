// behavioural
module full_adder(output reg sum, output reg cout, input A, input B, input cin);
always @(A or B or cin)
begin
    sum = A+B+cin;
    cout = ((A^B) & cin) | (A & B);
end
endmodule


module add_sub(output [3:0] res, output overflow, input [3:0] A, input [3:0] B, input M);
wire [3:0] w;
wire [3:0] c;

xor(w[0],M,B[0]);
xor(w[1],M,B[1]);
xor(w[2],M,B[2]);
xor(w[3],M,B[3]);

full_adder f1(res[0],c[0],A[0],w[0],M);
full_adder f2(res[1],c[1],A[1],w[1],c[0]);
full_adder f3(res[2],c[2],A[2],w[2],c[1]);
full_adder f4(res[3],c[3],A[3],w[3],c[2]);
assign overflow = c[2] ^ c[3];
endmodule

module testbench;
reg [3:0] A = 0;
reg [3:0] B = 0;
reg M = 0;
wire [3:0] res;
wire overflow;
integer i,j;

add_sub AS(res,overflow,A,B,M);

initial
$monitor($time," A=%b, B=%b, M=%b, result=%b, overflow=%b",A,B,M,res,overflow);

initial
begin
    for(i=0;i<=15;i=i+1)
    begin
        for(j=0;j<=15;j=j+1)
        begin
            #5 A=i;B=j;
        end
    M = i%2;
    end
end
endmodule