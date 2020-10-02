// gate-level
module bit_adder_gl(output sum, output cout, input A, input B, input cin);
wire w[0:3];
xor(w[0],A,B);
and(w[1],cin,w[0]);
and(w[2],A,B);

or(sum,cin,w[0]);
or(cout,w[1],w[2]);
endmodule

// dataflow
module bit_adder_df(output sum, output cout, input A, input B, input cin);
assign sum = A + B + cin;
assign cout = (A & B) || (A ^ B) & cin;
endmodule

// testbench
module bit_adder_tb;
wire sum,cout;
reg A,B,cin;
bit_adder_df ba(sum,cout,A,B,cin);
integer i,j,k;

initial
begin
    A=0;
    B=0;
    cin=0;
end

initial
begin
for(i=0;i<=1;i=i+1)
begin
    for(j=0;j<=1;j=B+1)
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