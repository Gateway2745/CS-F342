//VeriLog Code for 4 bit Shift Register.
module shiftreg(EN, in, CLK, Q);
parameter n = 4;
input EN;
input in;
input CLK;
output [n-1:0] Q;
reg [n-1:0] Q;
initial
Q=4'd10;
always @(posedge CLK)
begin
if (EN)
Q={in,Q[n-1:1]};
end
endmodule

// Test Bench of 4 bit shift register
module shiftregtest;
parameter n= 4;
reg EN,in , CLK;
wire [n-1:0] Q;

shiftreg shreg(EN,in,CLK,Q);
initial
CLK=0;

always
#2 CLK=~CLK;

initial
$monitor($time," EN=%b in= %b Q=%b\n",EN,in,Q);
initial
begin
in=0;EN=0;
#4 in=1;EN=1;
#4 in=1;EN=0;
#4 in=0;EN=1;
#5 $finish;
end
endmodule