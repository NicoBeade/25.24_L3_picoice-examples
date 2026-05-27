module ex5_top (
    output LED_B, output LED_G, output LED_R, input ICE_SW2
);
    wire [3:0] res; wire zero;
    control_structures inst(.a(4'd5), .b({3'd0, ICE_SW2}), .opcode(3'b000), .result(res), .zero_flag(zero));
    assign LED_G = zero;
    assign LED_R = res[0]; assign LED_B = 1'b1;
endmodule
