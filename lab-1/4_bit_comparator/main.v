// behavioural
module comparator_beh(output reg [2:0] out, input [3:0] A, input [3:0] B);
always @(A or B)
begin
    out=0;
    if(A>B) out[2]=1;
    else if (A<B) out[1]=1;
    else out[0]=1;
end
endmodule


// dataflow
module comparator_df(output [2:0] out, input [3:0] a, input [3:0] b);
assign out = a>b?3'b100:a<b?3'b010:3'b001;
endmodule


// gate-level
module comparator_gl(output [2:0] out, input [3:0] a, input [3:0] b);
wire [0:4] w[0:3];
wire [0:6] f;

not(w[0][0],a[3]);
not(w[0][1],b[3]);
and(w[0][2],w[0][0],b[3]);
and(w[0][3],w[0][1],a[3]);
nor(w[0][4],w[0][2],w[0][3]);

not(w[1][0],a[2]);
not(w[1][1],b[2]);
and(w[1][2],w[1][0],b[2]);
and(w[1][3],w[1][1],a[2]);
nor(w[1][4],w[1][2],w[1][3]);

not(w[2][0],a[1]);
not(w[2][1],b[1]);
and(w[2][2],w[2][0],b[1]);
and(w[2][3],w[2][1],a[1]);
nor(w[2][4],w[2][2],w[2][3]);

not(w[3][0],a[0]);
not(w[3][1],b[0]);
and(w[3][2],w[3][0],b[0]);
and(w[3][3],w[3][1],a[0]);
nor(w[3][4],w[3][2],w[3][3]);

and(f[0],w[0][4],w[1][2]);
and(f[1],w[0][4],w[1][3]);
and(f[2],w[0][4],w[1][4],w[2][2]);
and(f[3],w[0][4],w[1][4],w[2][3]);
and(f[4],w[0][4],w[1][4],w[2][4],w[3][2]);
and(f[5],w[0][4],w[1][4],w[2][4],w[3][3]);
and(f[6],w[0][4],w[1][4],w[2][4],w[3][4]);

or(out[1],w[0][2],f[0],f[2],f[4]);
or(out[2],w[0][3],f[1],f[3],f[5]);
or(out[0],f[6],0);
endmodule


// testbench
module comparator_tb;
reg [3:0] A;
reg [3:0] B;
wire [2:0] out;

comparator_gl c1(out,A,B);

initial
begin
    A = 4'b1111;
    B = 4'b0000;
    #10 A = 4'b0100;
    #10 B = 4'b0100;
    #20 $finish;
end

initial
begin
$dumpfile("test.vcd");
$dumpvars(0,comparator_tb);
$monitor("\nA : %b, B : %b, ANS:%b", A, B, out);
end
endmodule
