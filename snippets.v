// behavioural 3 bit counter with asynchronous clear
module COUNTER_3BIT(output reg [2:0] q, input clear, input clk);
initial
    q=0;
always @(clear)
    if(clear)
        q <= 0;
        
always @(posedge clk)
begin
    if(!clear)
        q <= q + 1;
end
endmodule

// behavioural TFF with synchronous clear
module TFF(output reg q, input t, input clk, input clear);
initial
    q <= 0;
always @(posedge clk)
begin
    if(clear)
        q <= 0;
    else
    begin
        if(t) q <= ~q;
        else q <= q;
    end 
end
endmodule


// d flip flop with synchronous set and reset
module d_ff(output reg q, input d, input clk, input set, input reset);
always @(posedge clk)
    case({set,reset})
    2'b00 : q <= d;
    2'b01 : q <= 1'b0;
    2'b10 : q <= 1'b1;
    2'b11 : q <= 1'bz;
    endcase
endmodule



// behavioural TFF with asynchronous clear
module TFF(output reg q, input t, input clk, input clear); 
always @(clear)
    if(clear) q <= 0;

always @(posedge clk)
begin
    if(!clear)
    begin
        if(t) q <= ~q;
        else q <= q;
    end
end
endmodule

// 3 : 8 decoder with asynchronous enable
module DECODER(output reg [7:0] q, input [2:0] in, input enable);
always @(enable)
begin
    if(!enable)
        q <= 0; 
end

always @(in)
begin
    if(enable) q = 1 << in;
end
endmodule