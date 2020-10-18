module d_ff(output reg q,input d,input clk,input reset);
initial
q=0;

always @(posedge clk) // do not add 'or reset' as when reset changes from 0 to 1, data will be written
begin
    if(!reset)
    begin
        q<=0;
    end
    else 
    begin
        q<=d;
    end
end
endmodule

module reg_32bit(output [31:0] q, input [31:0] d, input clk, input reset);
genvar i;
generate for(i=0;i<32;i=i+1)
begin
    d_ff d(q[i],d[i],clk,reset);
end
endgenerate
endmodule

module tb32reg;
reg [31:0] d;
reg clk,reset;
wire [31:0] q;
reg_32bit R(q,d,clk,reset);
always @(clk)
#5 clk<=~clk;
initial
begin
clk= 1'b1;
reset=1'b0;//reset the register
#20 reset=1'b1;
#20 d=32'hAFAFAFAF;
#200 $finish;
end
//initial
// monitor($time," d=%b,clk=%b,reset=%b,q=%b",d,clk,reset,q);
endmodule

module mux4_1(output [31:0] regData,input [31:0] q1,input [31:0] q2, input [31:0] q3, input [31:0] q4,input [1:0] reg_no);
assign regData = reg_no==2'b00 ? q1:
                 reg_no==2'b01 ? q2:
                 reg_no==2'b10 ? q3:
                 q4;
endmodule

module decoder2_4(output [3:0] register, input [1:0] reg_no);
assign register = 4'b1000>>reg_no;
endmodule

module tbdecoder2_4;
reg [1:0] reg_no = 2'b11;
wire [3:0] register;
decoder2_4 t(register,reg_no);

initial
begin
    $display("reg_no = %b, register = %b", reg_no, register);
end
endmodule

module RegFile(input clk,input reset,input[1:0] ReadReg1,input [1:0] ReadReg2,
               input [31:0] WriteData, input [1:0] WriteReg,
               input RegWrite, output [31:0] ReadData1, output [31:0] ReadData2);

wire [3:0] wr;
wire [3:0] new_clk;
wire [31:0] q1,q2,q3,q4;

decoder2_4 write_reg(wr, WriteReg);
assign new_clk = wr * RegWrite * clk;

reg_32bit r1(q1, WriteData, new_clk[3],reset);
reg_32bit r2(q2, WriteData, new_clk[2],reset);
reg_32bit r3(q3, WriteData, new_clk[1],reset);
reg_32bit r4(q4, WriteData, new_clk[0],reset);

mux4_1 read1(ReadData1, q1,q2,q3,q4,ReadReg1);
mux4_1 read2(ReadData2, q1,q2,q3,q4,ReadReg2);

endmodule

module tbRegFile;
reg clk, reset, RegWrite;
reg [1:0] ReadReg1,ReadReg2,WriteReg;
reg [31:0] WriteData;
wire [31:0] ReadData1, ReadData2;

RegFile r(clk, reset, ReadReg1, ReadReg2, WriteData, WriteReg, RegWrite, ReadData1, ReadData2);

always @(clk)
begin
    #5 clk <= ~clk;
end

initial begin
    $monitor(, $time, " clk=%d ReadData1=%b, ReadData2=%b, WriteData=%b",clk, ReadData1, ReadData2, WriteData);
    clk=1; reset=0; ReadReg1=2'b00; ReadReg2=2'b00; WriteReg=2'b00; RegWrite=1'b1;
    WriteData = 32'HAFAFAFAF;
    #10 reset = 1'b1; RegWrite = 1'b1;  WriteData = 32'hF0F0F0F0; WriteReg = 2'b00;
    #10 RegWrite = 1'b1;  WriteData = 32'hF8F8F8F8; WriteReg = 2'b01;
    #10 RegWrite = 1'b1;  WriteData = 32'hFAFAFAFA; WriteReg = 2'b10;
    #10 RegWrite = 1'b1;  WriteData = 32'hFFFFFFFF; WriteReg = 2'b11;
    #10 RegWrite = 1'b0;
    #10 ReadReg1 = 2'b00; ReadReg2 = 2'b01;
    #10 ReadReg1 = 2'b10; ReadReg2 = 2'b11;
    #20 $finish;
end


endmodule