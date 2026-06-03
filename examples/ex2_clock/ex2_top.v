module ex2_top (
    output LED_B, output LED_G, output LED_R, output ICE_31, input ICE_SW2
);
    clock_divider inst(
        .LED_B(LED_B), .LED_G(LED_G), .LED_R(LED_R), .ICE_31(ICE_31), .ICE_SW2(ICE_SW2)
    );
endmodule
