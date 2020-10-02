module DECODER(d0,d1,d2,d3,d4,d5,d6,d7,x,y,z);
input x,y,z;
output d0,d1,d2,d3,d4,d5,d6,d7;
wire x0,y0,z0;
not n1(x0,x);
not n2(y0,y);
not n3(z0,z);
and a0(d0,x0,y0,z0);
and a1(d1,x0,y0,z);
and a2(d2,x0,y,z0);
and a3(d3,x0,y,z);
and a4(d4,x,y0,z0);
and a5(d5,x,y0,z);
and a6(d6,x,y,z0);
and a7(d7,x,y,z);
endmodule

module FADDER(s,c,x,y,z);
input x,y,z;
wire d0,d1,d2,d3,d4,d5,d6,d7;
output s,c;
DECODER dec(d0,d1,d2,d3,d4,d5,d6,d7,x,y,z);
assign s = d1 | d2 | d4 | d7, c = d3 | d5 | d6 | d7;
endmodule

module eight_bit_adder(output cout, output [7:0] out, input [7:0] A, input[7:0] B, input carry);
wire [6:0] c;
FADDER f1(out[0], c[0], A[0], B[0],carry);
FADDER f2(out[1],c[1],A[1],B[1],c[0]);
FADDER f3(out[2],c[2],A[2],B[2],c[1]);
FADDER f4(out[3],c[3],A[3],B[3],c[2]);
FADDER f5(out[4],c[4],A[4],B[4],c[3]);
FADDER f6(out[5],c[5],A[5],B[5],c[4]);
FADDER f7(out[6],c[6],A[6],B[6],c[5]);
FADDER f8(out[7],cout,A[7],B[7],c[6]);
endmodule

module four_byte_adder(output cout, output [31:0] out, input [31:0] A, input[31:0] B, input carry);
wire [3:0] c;
eight_bit_adder f1(c[0], out[7:0], A[7:0], B[7:0],carry);
eight_bit_adder f2(c[1],out[15:8],A[15:8],B[15:8],c[0]);
eight_bit_adder f3(c[2],out[23:16],A[23:16],B[23:16],c[1]);
eight_bit_adder f4(c[3],out[31:24],A[31:24],B[31:24],c[2]);
assign cout = c[3];
endmodule

module testbench;
reg [31:0] A = 0; 
reg [31:0] B = 0;
reg carry = 0;
output [31:0] sum;
output cout;
four_byte_adder b(cout,sum,A,B,carry);
integer i,j;

initial
$monitor($time," A=%b, B=%b, sum=%b, cout=%b",A,B,sum,cout);

initial
begin
    for(i=32'b0;i<=32'b00000111;i=i+1)
    begin
        for(j=32'b0;j<=32'b00001111;j=j+1)
        begin
            #5 A=i;B=j;carry=0;
        end
    end
end
endmodule