// to-do : fix when input changes multiple times before next clock pulse  

module mealy(output reg rec, input x, input reset, input clk);
reg [2:0] state;
reg [2:0] nextstate;
parameter S0=3'b000,S1=3'b001,S2=3'b010,S3=3'b011,S4=3'b100;

always @(posedge clk or posedge reset)
begin
    if(reset)
    state=S0;
    else 
    state = nextstate;
end

always @(state or x)
begin
    rec=0;
    case(state)
        S0:
        begin
            if(x) nextstate=S1;
            else nextstate=S0;
        end
        S1:
        begin
            if(x) nextstate=S1;
            else nextstate=S2;
        end
        S2:
        begin
            if(x) nextstate=S3;
            else nextstate=S0;
        end
        S3:
        begin
            if(x) nextstate=S4;
            else nextstate=S2;
        end
        S4:
        begin
            if(x) nextstate=S1;
            else 
            begin
                nextstate=S2;
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
        $display("State = ", m.state, " Input = ", x, " Output =", rec);
        #2 clk=1;
        #2 clk=0; 
    end
    // #100 $finish;
end

endmodule