module five_bit_reg(output reg [4:0] out, input [4:0] in, input clk, input reset);
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
        DM[i] =32'b0;
    end
end
endmodule

module read_IM(output [31:0] out, input [31:0][31:0] IM, input [4:0] PC);
assign out = IM[PC];
endmodule



module SCDataPath;
reg [4:0] PC_in = 5'b00000;
reg clk=0;
reg PC_reset=1;
wire [4:0] PC_out;
five_bit_reg PC(PC_out, PC_in, clk, reset);

wire [31:0][31:0] IM;
IM_instantiate IM_instant(IM);

wire [31:0][31:0] DM;
DM_instantiate DM_instant(DM);

wire [31:0] instruction;
read_IM rim(instruction,IM,PC_out);

wire RegDst,ALUSrc,MemtoReg, RegWrite, MemRead, MemWrite,Branch,ALUOp1,ALUOp2;
wire Rformat,lw,sw,beq;
ControlUnit cu(RegDst,ALUSrc,MemtoReg, RegWrite, MemRead, MemWrite,Branch,ALUOp1,ALUOp2,instruction[31:26]);



endmodule
