`timescale 1ns/1ps
module ex3_tb;
    reg clk, a, b;
    wire c_out, s_out;
    wire_vs_reg uut(.clk(clk), .a(a), .b(b), .combinational_out(c_out), .sequential_out(s_out));
    initial begin clk=0; forever #5 clk=~clk; end
    initial begin
        $dumpvars(0, ex3_tb);
        a=0; b=0; #10;
        a=1; b=1; #20;
        $finish;
    end
endmodule
