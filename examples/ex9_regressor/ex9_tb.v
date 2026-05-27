`timescale 1ns/1ps
module ex9_tb;
    reg clk, rst; reg signed [7:0] din;
    wire [31:0] taps;
    regressor uut(.clk(clk), .rst(rst), .data_in(din), .flat_taps(taps));
    initial begin clk=0; forever #5 clk=~clk; end
    initial begin
        $dumpvars(0, ex9_tb);
        rst=1; din=0; #10;
        rst=0; din=10; #10;
        din=20; #10; din=30; #20;
        $finish;
    end
endmodule
