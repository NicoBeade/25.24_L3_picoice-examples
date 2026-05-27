`timescale 1ns/1ps
module ex12_tb;
    reg clk, rst; reg [7:0] inc;
    wire signed [7:0] sine;
    sine_lut uut(.clk(clk), .rst(rst), .phase_inc(inc), .sine_out(sine));
    initial begin clk=0; forever #5 clk=~clk; end
    initial begin
        $dumpvars(0, ex12_tb);
        rst=1; inc=8'd16; #10;
        rst=0; #200;
        $finish;
    end
endmodule
