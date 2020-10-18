// assume input changes only once before next clock pulse

module mealy(output reg rec, input x, input reset, input clk);
reg [2:0] state;
parameter S0=3'b000,S1=3'b001,S2=3'b010,S3=3'b011,S4=3'b100;

always @(posedge clk or posedge reset)
if(reset)
begin
    state=S0;
    rec=0;
end
else
begin
    rec=0;
    case(state)
        S0:
        begin
            if(x) state=S1;
            else state=S0;
        end
        S1:
        begin
            if(x) state=S1;
            else state=S2;
        end
        S2:
        begin
            if(x) state=S3;
            else state=S0;
        end
        S3:
        begin
            if(x) state=S4;
            else state=S2;
        end
        S4:
        begin
            if(x) state=S1;
            else 
            begin
                state=S2;
                rec=1;
            end
        end
    endcase
end
endmodule

// testbench
module testbench;
reg x,reset,clk;
reg [0:24] sequence;
wire rec;
mealy m(rec,x,reset,clk);
integer i;

initial
begin
    // $monitor($time," clk=%b reset= %b x=%b result=%b state=%b\n",clk,reset,x,rec,m.state);
    clk=0;
    reset=1;
    sequence=25'b00110_10110_00100_10111_00110;
    #5 reset=0;
    for(i=0;i<=24;i=i+1)
    begin
        x=sequence[i];
        #2 clk=1;
        #2 clk=0; 
        $display("State = ", m.state, " Input = ", x, " Output =", rec);
    end
    // #100 $finish;
end

endmodule