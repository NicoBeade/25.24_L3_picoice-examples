module ex6_top (
    output LED_B, output LED_G, output LED_R, input ICE_SW2
);
    wire signed [15:0] din = ICE_SW2 ? 16'h00A5 : 16'h8A00;
    wire signed [7:0] t, r, s;
    trunc_round_sat inst(.data_in(din), .data_trunc(t), .data_round(r), .data_sat(s));
    assign LED_G = t[0]; assign LED_R = r[0]; assign LED_B = s[0];
endmodule
