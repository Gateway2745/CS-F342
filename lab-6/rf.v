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

module mux32_1(output [31:0] regData, input [31:0][31:0] RF, input [4:0] reg_no);
assign regData = RF[reg_no];
endmodule

module decoder5_32(output [31:0] out, input [4:0] in); // follows diagram in lab sheet
assign out = 32'h80000000 >> in; 
endmodule

module RegFile(clk,reset,ReadReg1,ReadReg2,WriteData,WriteReg,RegWrite,ReadData1,ReadData2);
input clk,reset,RegWrite;
input [4:0] WriteReg,ReadReg1,ReadReg2;
input [31:0] WriteData;
output [31:0] ReadData1,ReadData2;
wire [31:0] wr;
wire [31:0] new_clk;
wire [31:0][31:0] RF;

decoder5_32 write_reg(wr, WriteReg);
assign new_clk = wr * RegWrite * clk;

generate
    genvar i;
    for (i = 0; i < 32; i = i + 1) begin
        reg_32bit rf(RF[i],WriteData,new_clk[31-i],reset);
    end
endgenerate

mux32_1 read1(ReadData1,RF,ReadReg1);
mux4_1 read2(ReadData2,RF,ReadReg2);
endmodule
