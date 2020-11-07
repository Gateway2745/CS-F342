// gate-level
module converter_gl(output [3:0] out, input [3:0] in);
xor (out[3],in[3],0);
xor (out[2], in[3], in[2]);
xor (out[1], in[2], in[1]);
xor (out[0], in[1], in[0]);
endmodule

// dataflow
module converter(output [3:0] out, input [3:0] in);
assign out= {in[3], in[3] & in[2], in[2] ^ in[1], in[1] ^ in[0]};
endmodule


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
$monitor("Time = %0d , BCD : %b , GRAY_CODE : %b", $time, in, out);
end
endmodule