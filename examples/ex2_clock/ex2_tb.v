`timescale 1ns/1ps
module ex2_tb;
    reg ICE_SW2;
    wire LED_B, LED_G, LED_R, ICE_31;
    ex2_top uut(.LED_B(LED_B), .LED_G(LED_G), .LED_R(LED_R), .ICE_31(ICE_31), .ICE_SW2(ICE_SW2));
    initial begin
        $dumpvars(0, ex2_tb);
        ICE_SW2 = 0; #100;
        $finish;
    end
endmodule
