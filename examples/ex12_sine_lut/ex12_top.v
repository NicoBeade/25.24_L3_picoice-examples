module ex12_top (
    output LED_B, output LED_G, output LED_R, input ICE_SW2
);
    wire clk;
    SB_HFOSC #(.CLKHF_DIV("0b10")) u_hfosc (.CLKHFEN(1'b1), .CLKHFPU(1'b1), .CLKHF(clk));
    wire signed [7:0] sine;
    sine_lut inst(.clk(clk), .rst(1'b0), .phase_inc(8'd10), .sine_out(sine));
    assign LED_G = sine[7]; assign LED_R = 1'b1; assign LED_B = 1'b1;
endmodule
