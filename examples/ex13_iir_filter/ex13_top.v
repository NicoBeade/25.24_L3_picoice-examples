module ex13_top (
    output LED_B, output LED_G, output LED_R, input ICE_SW2
);
    wire clk;
    SB_HFOSC #(.CLKHF_DIV("0b10")) u_hfosc (.CLKHFEN(1'b1), .CLKHFPU(1'b1), .CLKHF(clk));
    wire signed [15:0] dout;
    iir_filter inst(.clk(clk), .rst(1'b0), .din({15'd0, ICE_SW2}), .dout(dout));
    assign LED_G = dout[0]; assign LED_R = 1'b1; assign LED_B = 1'b1;
endmodule
