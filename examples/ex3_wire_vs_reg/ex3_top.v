module ex3_top (
    output LED_B, output LED_G, output LED_R, input ICE_SW2
);
    wire clk;
    SB_HFOSC #(.CLKHF_DIV("0b10")) u_hfosc (.CLKHFEN(1'b1), .CLKHFPU(1'b1), .CLKHF(clk));
    
    wire c_out, s_out;
    wire_vs_reg inst(.clk(clk), .a(ICE_SW2), .b(1'b1), .combinational_out(c_out), .sequential_out(s_out));
    
    assign LED_G = c_out;
    assign LED_R = s_out;
    assign LED_B = 1'b1;
endmodule
