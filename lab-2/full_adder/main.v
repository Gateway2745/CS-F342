// behavioural
module full_adder(output sum, output cout, input A, input B, input cin);
always @(A or B or  cin)
begin
    sum = A+B+cin;
    cout = ((A^B) & cin) | (A & B);
end
endmodule


