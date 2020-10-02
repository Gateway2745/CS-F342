module bit_adder(output sum, output cout, input A, input B, input cin);
assign sum = A + B + cin;
assign cout = (A & B) || (A ^ B) & cin;
endmodule

module four_bit_adder(output [3:0]sum, output cout, input [3:0]A, input [3:0]B, input cin);
wire w[3:0];
assign cout = w[3];
bit_adder ba0(sum[0],w[0],A[0],B[0],cin);
bit_adder ba1(sum[1],w[1],A[1],B[1],w[0]);
bit_adder ba2(sum[2],w[2],A[2],B[2],w[1]);
bit_adder ba3(sum[3],w[3],A[3],B[3],w[2]);

endmodule

// testbench
module bit_adder_tb;
wire [3:0] sum;
wire cout;
reg [3:0] A;
reg [3:0] B;
reg cin;
four_bit_adder ba(sum,cout,A,B,cin);
integer i,j,k;

initial
begin
    A=0;
    B=0;
    cin=0;
end

initial
begin
for(i=0;i<=15;i=i+1)
begin
    for(j=0;j<=15;j=B+1)
    begin
        for(k=0;k<=1;k=k+1)
        begin
            #5 A=i;B=j;cin=k; 
        end
    end
end
end
initial
$monitor($time," A=%b,B=%b,Cin=%b,Sum=%b,Cout=%b",A,B,cin,sum,cout);
endmodule