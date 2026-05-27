`timescale 1ns/1ps
module ex6_tb;
    reg signed [15:0] din;
    wire signed [7:0] t, r, s;
    trunc_round_sat uut(.data_in(din), .data_trunc(t), .data_round(r), .data_sat(s));
    initial begin
        $dumpvars(0, ex6_tb);
        din = 16'h00FF; #10;
        din = 16'h7FFF; #10; // Max positive -> Saturation expected
        din = 16'h8000; #10; // Max negative -> Saturation expected
        $finish;
    end
endmodule
