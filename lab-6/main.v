module five_bit_reg(output reg [4:0] out, input [4:0] in, input clk, input reset); // for PC
initial
out=0;
always @(posedge clk)
begin
    if(!reset) 
        out <=0;
    else
    begin
        out <= in;
    end
end
endmodule

module IM_instantiate(output reg [31:0][31:0] IM);
integer i;
initial
begin
    for(i=0;i<=31;i=i+1)
    begin
        IM[i] =32'b000000_00100_00101_10100_00000_100000;
    end
end
endmodule

module DM_instantiate(output reg [31:0][31:0] DM);
integer i;
initial
begin
    for(i=0;i<=31;i=i+1)
    begin
        DM[i] =i;
    end
end
endmodule

module read_IM(output [31:0] out, input [31:0][31:0] IM, input [4:0] PC);
assign out = IM[PC];
endmodule



module SCDataPath(ALU_output,PC,reset,clk);
input reset, clk;

input [4:0] PC;
wire [4:0] PC_out;
five_bit_reg pc(PC_out, PC, clk, reset);

wire [31:0][31:0] IM;
IM_instantiate IM_instant(IM);

wire [31:0][31:0] DM;
DM_instantiate DM_instant(DM);

wire [31:0] instruction;
read_IM rim(instruction,IM,PC_out);

wire RegDst,ALUSrc,MemtoReg, RegWrite, MemRead, MemWrite,Branch,ALUOp1,ALUOp2;
wire Rformat,lw,sw,beq;
ControlUnit cu(RegDst,ALUSrc,MemtoReg, RegWrite, MemRead, MemWrite,Branch,ALUOp1,ALUOp2,instruction[31:26]);

wire [4:0] ReadReg1,ReadReg2,WriteReg;
wire [31:0] ReadData1,ReadData2,WriteData;
assign ReadReg1 = instruction[25:21];
assign ReadReg2 = instruction[20:16];
assign RegWrite = instruction[15:11];
RegFile rf(clk,reset,ReadReg1,ReadReg2,WriteData,WriteReg,RegWrite,ReadData1,ReadData2);

wire [1:0] aluop;
assign aluop = {ALUOp1,ALUOp2};
wire [2:0] alucontrol;
ALUcontrol aluc(alucontrol, aluop, instruction[5:0]);

output [31:0] ALU_output;
wire carry_out;
ALU alu(carry_out, ALU_output, ReadData1, ReadData2, alucontrol);

assign WriteData = ALU_output;
endmodule


module TestBench;
wire [31:0] ALU_output;
reg [4:0] PC=0;
reg rst=0,clk;
SCDataPath SCDP(ALU_output,PC,reset,clk);

initial
begin
$monitor("at time %0d IPC = %d, Reset = %d , CLK = %d ,ALU Output = %b instruction = %b",$time,PC,rst,clk, ALU_output,SCDP.instruction);
#0 clk = 0; PC = 5;
#20 rst = 1;
#400 $finish;
end
always
begin
#20 clk = ~clk;
end
endmodule
