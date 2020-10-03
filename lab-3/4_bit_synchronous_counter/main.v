module jk_ff(output reg q, input j, input k, input clk);
initial
q=0;
always @(posedge clk)
begin
    if(j==1 && k==0)
    begin
        q=1;
    end
    else if(j==0 && k==1)
    begin
        q=0;
    end
    else if(j==1 && k==1)
    begin
        q=~q;
    end
end
endmodule

module counter(output [3:0]q, input clk);
wire w[0:1];
and(w[0],q[0],q[1]);
and(w[1],w[0],q[2]);
jk_ff f1(q[0],1'b1,1'b1,clk);
jk_ff f2(q[1],q[0],q[0],clk);
jk_ff f3(q[2],w[0],w[0],clk);
jk_ff f4(q[3],w[1],w[1],clk);

endmodule

module testbench;
wire [3:0]q;
reg clk=0;
counter c(q,clk);
always
begin
    #2 clk=~clk;
end

initial
begin
    $monitor($time, " q=%b", q);
    #40 $finish;
end
endmodule
