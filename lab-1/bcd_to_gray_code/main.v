// gate-level
module converter_gl(output [3:0] out, input [3:0] in);
wire [7:0] w;

assign out[3] = in[3];
and(out[2], in[3], in[2]);

not(w[0], in[2]);
and(w[1], w[0], in[1]);

not(w[2],in[1]);
and(w[3], w[2], in[2]);

or(out[1], w[3], w[1]);

not(w[4], in[1]);
and(w[5], w[4], in[0]);

not(w[6], in[0]);
and(w[7], w[6], in[1]);

or(out[0], w[7], w[5]);
endmodule

// dataflow
module converter(output [3:0] out, input [3:0] in);
assign out= {in[3], in[3] & in[2], in[2] ^ in[1], in[1] ^ in[0]};
endmodule


// testbench
module converted_tb;
reg [3:0] in;
wire [3:0] out;

converter c1(out,in);

initial
begin
    in = 4'b0000;
    #10 in = 4'b0001;
    #20 in = 4'b0010;
    #30 in = 4'b0011;
    #40 $finish;
end

initial
begin
$dumpfile("test.vcd");
$dumpvars(0,converted_tb);
$monitor("Time: %d\nBCD : %b\nGRAY_CODE : %b\n", $time, in, out);
end
endmodule