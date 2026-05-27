`timescale 1ns/1ps
module ex13_tb;
    reg clk, rst; reg signed [15:0] din;
    wire signed [15:0] dout;
    iir_filter uut(.clk(clk), .rst(rst), .din(din), .dout(dout));
    initial begin clk=0; forever #5 clk=~clk; end
    initial begin
        $dumpvars(0, ex13_tb);
        rst=1; din=0; #10;
        rst=0; din=1000; #100;
        din=0; #100;
        $finish;
    end
endmodule
