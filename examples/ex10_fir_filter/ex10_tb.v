`timescale 1ns/1ps
module ex10_tb;
    reg clk, rst; reg signed [7:0] din;
    wire signed [17:0] dout;
    fir_filter uut(.clk(clk), .rst(rst), .din(din), .dout(dout));
    initial begin clk=0; forever #5 clk=~clk; end
    initial begin
        $dumpvars(0, ex10_tb);
        rst=1; din=0; #10;
        rst=0; din=100; #10;
        din=0; #50;
        $finish;
    end
endmodule
