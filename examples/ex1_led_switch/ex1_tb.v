`timescale 1ns/1ps
module ex1_tb;
    reg ICE_SW2;
    wire LED_B, LED_G, LED_R;
    ex1_top uut(.LED_B(LED_B), .LED_G(LED_G), .LED_R(LED_R), .ICE_SW2(ICE_SW2));
    initial begin
        $dumpvars(0, ex1_tb);
        ICE_SW2 = 0; #10;
        ICE_SW2 = 1; #10;
        $finish;
    end
endmodule
