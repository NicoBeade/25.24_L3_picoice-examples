module ex4_top (
    output LED_B, output LED_G, output LED_R, input ICE_SW2
);
    wire [7:0] din = {7'b0, ICE_SW2};
    wire [7:0] dout;
    for_loop_example inst(.data_in(din), .data_out_reversed(dout));
    assign LED_G = dout[7];
    assign LED_R = 1'b1; assign LED_B = 1'b1;
endmodule
