`define ADD 3'b000
`define SUB 3'b001
`define XOR 3'b010
`define OR 3'b011
`define AND 3'b100
`define NOR 3'b101
`define NAND 3'b110
`define XNOR 3'b111

module encoder(output reg [2:0] opcode,input [7:0] fncode);
always @(fncode) begin
    case (fncode)
        8'b00000001 : opcode = `ADD;
        8'b00000010 : opcode = `SUB;
        8'b00000100 : opcode = `XOR;
        8'b00001000 : opcode = `OR;
        8'b00010000 : opcode = `AND;
        8'b00100000 : opcode = `NOR;
        8'b01000000 : opcode = `NAND;
        8'b10000000 : opcode = `XNOR;
    endcase
end
endmodule

module ALU(output [3:0] out, input [3:0] A, input [3:0] B, input [2:0] opcode);
assign out = opcode == `ADD ? A + B :
             opcode == `SUB ? A - B :
             opcode == `XOR ? A ^ B :
             opcode == `OR ? A | B :
             opcode == `AND ? A & B :
             opcode == `NOR ? ~(A | B) :
             opcode == `NAND ? ~(A & B) :
             opcode == `XNOR ? ~(A ^ B) :
             0;
endmodule

module even_parity_gen(output out, input [3:0] A);
assign out = A[0] ^ A[1] ^ A[2] ^ A[3];
endmodule

module pipelineS1(regA,regB,regOP, A, B, fncode, clk);
output reg [3:0] regA, regB;
output reg [2:0] regOP;
input [3:0] A,B;
input [7:0] fncode;
input clk;

wire [2:0] opcode;
encoder enc(opcode,fncode);

always @(posedge clk)
begin
    regA <= A;
    regB <= B;
    regOP <= opcode;
end
endmodule

module pipelineS2(regRes, A, B, opcode, clk);
output reg [3:0] regRes;
input [3:0] A, B;
input [2:0] opcode;
input clk;

wire [3:0] res;
ALU alu(res, A, B, opcode);

always @(posedge clk)
begin
    regRes <= res;
end
endmodule

module pipeline(parity, A, B, fncode,clk);
output parity;
input [3:0] A,B;
input [7:0] fncode;
input clk;

wire [3:0] wA, wB;
wire [2:0] wOP;
pipelineS1 ps1(wA,wB,wOP,A,B,fncode,clk);

wire [3:0] wRes;
pipelineS2 ps2(wRes,wA,wB,wOP,clk);

even_parity_gen epg(parity,wRes);
endmodule


module tb;
reg clk;
reg [3:0] A,B;
reg [7:0] fncode;

wire parity;
pipeline pl(parity,A,B,fncode,clk);

initial
begin
    clk=0;
    // regA and regB are stage 1 registers while regRes is stage 2 register(holds arithmetic result)
    $monitor($time, " clk = %b , regA=%d, regB=%d, regRes=%b, parity = %b",clk ,pl.ps1.regA,pl.ps1.regB,B,pl.ps2.regRes,pl.parity);
    A=7;B=3;fncode=8'b00000001;
    #4 A=12;B=10;fncode=8'b00000010;
    #4 A=13;B=5;fncode=8'b00000001;
    #20 $finish;
end

always
begin
    #2 clk = ~clk;
end

endmodule
