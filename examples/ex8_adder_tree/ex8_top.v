module ex8_top (
    output LED_B, output LED_G, output LED_R, input ICE_SW2
);
    wire [31:0] flat_in = {8'd10, 8'd20, 8'd30, 8'd40}; // sum = 100
    wire [9:0] sum;
    adder_tree inst(.flat_inputs(flat_in), .sum_out(sum));
    assign LED_G = sum[0]; assign LED_R = 1'b1; assign LED_B = 1'b1;
endmodule
