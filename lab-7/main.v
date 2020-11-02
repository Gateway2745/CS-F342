module mc_controller(S,op,NS,PCWrite,PCWriteCond,IorD,MemRead,MemWrite,IRWrite,MemtoReg,
                    PCSrc,ALUOp,ALUSrcA,ALUSrcB,RegWrite,
                    RegDst);
input [5:0] op;
input [3:0] S;
output [1:0] ALUSrcB, ALUOp, PCSrc;
output [3:0] NS;
output PCWrite,PCWriteCond,IorD,MemRead,MemWrite,IRWrite,MemtoReg,ALUOp1,ALUOp0,ALUSrcB1,ALUSrcB0,ALUSrcA,RegWrite,RegDst;

assign PCWrite = (~S[3]&~S[2]&~S[1]&~S[0]) | (S[3]&~S[2]&~S[1]&S[0]);
assign PrWriteCond = S[3]&~S[2]&~S[1]&~S[0];
assign IorD = (~S[3]&~S[2]&S[1]&S[0]) | (~S[3]&S[2]&~S[1]&S[0]);
assign MemR = (~S[3]&~S[2]&~S[1]&~S[0]) | (~S[3]&~S[2]&S[1]&S[0]);
assign MemW = ~S[3]&S[2]&~S[1]&S[0];
assign IRWrite = ~S[3]&~S[2]&~S[1]&~S[0];
assign MemtoReg = ~S[3]&S[2]&~S[1]&~S[0];
assign RegWr = (~S[3]&S[2]&~S[1]&~S[0]) | (~S[3]&S[2]&S[1]&S[0]);
assign RegDst = ~S[3]&S[2]&S[1]&S[0];
assign ALUSrcA = (~S[3]&~S[2]&S[1]&~S[0]) | (~S[3]&S[2]&S[1]&~S[0]) | (S[3]&~S[2]&~S[1]&~S[0]);

assign ALUSrcB[1] = (~S[3]&~S[2]&~S[1]&S[0]) | (~S[3]&~S[2]&S[1]&~S[0]);
assign ALUSrcB[0] = (~S[3]&~S[2]&~S[1]&~S[0]) | (~S[3]&~S[2]&~S[1]&S[0]);

assign ALUOp[1] = ~S[3]&S[2]&S[1]&~S[0];
assign ALUOp[0] = S[3]&~S[2]&~S[1]&~S[0];

assign PCSrc[1] = S[3]&~S[2]&~S[1]&S[0];
assign PCSrc[0] = S[3]&~S[2]&~S[1]&~S[0];

//next state
assign NS[3] = (S[3]&~S[2]&~S[1]&~S[0]&~op[5]&~op[4]&~op[3]&~op[2]&op[1]&~op[0]) | (S[3]&~S[2]&~S[1]&S[0]&~op[5]&~op[4]&~op[3]&op[2]&~op[1]&~op[0]);
assign NS[2] = (~S[3]&~S[2]&~S[1]&S[0]&~op[5]&~op[4]&~op[3]&~op[2]&~op[1]&~op[0]) | (~S[3]&~S[2]&S[1]&~S[0]&op[5]&~op[4]&op[3]&~op[2]&op[1]&op[0]) | 
                (~S[3]&~S[2]&S[1]&S[0]) | (~S[3]&S[2]&S[1]&~S[0]);
assign NS[1] = (~S[3]&~S[2]&~S[1]&S[0]&~op[5]&~op[4]&~op[3]&~op[2]&~op[1]&~op[0]) | (~S[3]&~S[2]&~S[1]&S[0]&op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0]) | 
                (~S[3]&~S[2]&~S[1]&S[0]&op[5]&~op[4]&op[3]&~op[2]&op[1]&op[0]) | (~S[3]&~S[2]&S[1]&~S[0]) | (~S[3]&S[2]&S[1]&~S[0]);
assign NS[0] = (~S[3]&~S[2]&~S[1]&~S[0]) | (~S[3]&~S[2]&~S[1]&S[0]&~op[5]&~op[4]&~op[3]&~op[2]&op[1]&~op[0]) | (~S[3]&~S[2]&S[1]&~S[0]) | (~S[3]&S[2]&S[1]&~S[0]);

endmodule

module testbench;
	reg[3:0] s;
	reg[5:0] op;
	wire[3:0] ns;
	wire PCWrite,PrWriteCond,IorD,MemR,MemW,IRWrite,MemtoReg,RegWr,RegDst,ALUSrcA;
	wire[1:0] ALUOp,ALUSrcB,PCSrc;
	mc_controller mcc(s,op,ns,PCWrite,PrWriteCond,IorD,MemR,MemW,IRWrite,MemtoReg,PCSrc,ALUOp,ALUSrcA,ALUSrcB,RegWr,RegDst);
	
	initial
	begin
        $monitor(,$time," Next State=%4b",ns);
        op = 6'b100011;
		s = 4'b0000;
		#5 s=4'b0001;
		#5 s=4'b0010;
		#5 s=4'b0011;
		$finish;
	end
endmodule
