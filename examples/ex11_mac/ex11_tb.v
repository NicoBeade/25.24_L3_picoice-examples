`timescale 1ns/1ps
module ex11_tb;
    reg clk, rst, clr; reg signed [15:0] a, b;
    wire signed [31:0] acc;
    mac uut(.clk(clk), .rst(rst), .clr(clr), .a(a), .b(b), .acc(acc));
    initial begin clk=0; forever #5 clk=~clk; end
    initial begin
        $dumpvars(0, ex11_tb);
        rst=1; clr=0; a=0; b=0; #10;
        rst=0; a=10; b=5; #10; // 50
        clr=1; #10;            // clr, acc=50
        clr=0; a=2; b=3; #20;  // 56, 62
        $finish;
    end
endmodule
