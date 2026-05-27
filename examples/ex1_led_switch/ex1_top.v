module ex1_top (
    output LED_B, output LED_G, output LED_R, input ICE_SW2
);
    led_switch inst(
        .LED_B(LED_B), .LED_G(LED_G), .LED_R(LED_R), .ICE_SW2(ICE_SW2)
    );
endmodule
