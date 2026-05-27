module ex11_top (
    output LED_B, output LED_G, output LED_R, input ICE_SW2
);
    wire clk;
    SB_HFOSC #(.CLKHF_DIV("0b10")) u_hfosc (.CLKHFEN(1'b1), .CLKHFPU(1'b1), .CLKHF(clk));
    wire signed [31:0] acc;
    mac inst(.clk(clk), .rst(1'b0), .clr(ICE_SW2), .a(16'd5), .b(16'd2), .acc(acc));
    assign LED_G = acc[0]; assign LED_R = 1'b1; assign LED_B = 1'b1;
endmodule
