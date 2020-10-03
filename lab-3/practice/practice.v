module sample(output reg d, output reg a, output reg b, output reg c);
initial
begin
fork
#5 a = 1'b1;
#10 b = 1'b0;
#15 c = 1'b1;
join
#30 d = 1'b0;
end
endmodule

module testbench;
wire a,b,c,d;
sample S(d,a,b,c);
always @(a or b or c or d)
begin
    $display($time, " a=%b, b=%b, c=%b, d=%b\n", a, b, c, d);
end
initial
#100 $finish;
endmodule