`timescale 1us/1us

module MUX_2X1(output q, input [1:0] in, input sel); // mux in dataflow
assign q = sel == 0 ? in[0]:in[1];
endmodule

module MUX_8X1(output q, input [7:0] in, input [2:0] sel);
assign q = sel == 3'b000 ? in[0] : 
           sel == 3'b001 ? in[1] : 
           sel == 3'b010 ? in[2] : 
           sel == 3'b011 ? in[3] : 
           sel == 3'b100 ? in[4] : 
           sel == 3'b101 ? in[5] : 
           sel == 3'b110 ? in[6] : 
           sel == 3'b111 ? in[7] : 
           0;
endmodule

module MUX_ARRAY(output [7:0] q, input [7:0][1:0] in, input [7:0] sel);
genvar i;
generate 
    for(i=0;i<8;i=i+1)
    begin
        MUX_2X1 m21(q[i],in[i],sel[i]);
    end
endgenerate
endmodule

module COUNTER_3BIT(output reg [2:0] q, input clear, input clk);
initial
    q=0;

always @(clear)
begin
    if(clear)
        q <= 0;
end

always @(posedge clk)
begin
    if(!clear)
        q <= q + 1;
end
endmodule

module DECODER(output reg [7:0] q, input [2:0] in, input enable);
always @(enable)
begin
    if(!enable)
        q <= 0; 
end

always @(in)
begin
    if(enable)
    begin
        case(in)
        3'b000 : q = 8'b00000001;
        3'b001 : q = 8'b00000010;
        3'b010 : q = 8'b00000100;
        3'b011 : q = 8'b00001000;
        3'b100 : q = 8'b00010000;
        3'b101 : q = 8'b00100000;
        3'b110 : q = 8'b01000000;
        3'b111 : q = 8'b10000000;
        endcase
    end 
end

endmodule

module MEMORY(output reg [7:0] q, input [2:0] in);
reg [7:0][7:0] mem;
initial
begin
    mem[0] = 8'h01;
    mem[1] = 8'h3;
    mem[2] = 8'h7;
    mem[3] = 8'hf;
    mem[4] = 8'h1f;
    mem[5] = 8'h3f;
    mem[6] = 8'h7f;
    mem[7] = 8'hff;
end

always @(in)
begin
    case(in)
    3'b000 : q = mem[0];
    3'b001 : q = mem[1];
    3'b010 : q = mem[2];
    3'b011 : q = mem[3];
    3'b100 : q = mem[4];
    3'b101 : q = mem[5];
    3'b110 : q = mem[6];
    3'b111 : q = mem[7];
    endcase
end

endmodule

module TOP_MODULE(output o, input clk, input clear, input enable, input [2:0] addr);

wire [2:0] ctr_out;
COUNTER_3BIT ctr(ctr_out,clear,clk);

wire [7:0] dec_out;
DECODER dec(dec_out,ctr_out,enable);

wire [7:0] mem_out;
MEMORY memory(mem_out,addr);

wire [7:0][1:0] mux_in;
wire [7:0] marray_out;
MUX_ARRAY marray(marray_out, mux_in, mem_out);

MUX_8X1 mux81(o,marray_out,ctr_out);

genvar i;
generate
    for(i=0;i<8;i=i+1)
    begin
        assign mux_in[i][0]=1'b0;
        assign mux_in[i][1]=dec_out[i];
    end
endgenerate

endmodule


module testbench;
wire out;
reg clk, clear, enable;
reg [2:0] addr;

TOP_MODULE tm(out,clk,clear,enable,addr);

initial
begin
    $monitor("time : %0d , clk : %b , addr : %b , clear : %b , counter = %b , output : %b",$time,clk,addr,clear,tm.ctr_out,out);
    addr = 3'b000;
    enable=1;
    #100 clear=1;
    #100 clear = 0;
    clk=0;
    #65000 $finish;
end

always
    #1000 clk = ~clk;
always 
    #8000 addr = addr + 1;
endmodule