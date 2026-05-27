/*******************************************************************************
*                   ITBA - 25.24 Laboratorio de Electrónica III
*
* - Author: Nicolás Beade / AI Assistant
* - Description: Complete FIR Filter instantiating the Regressor (ex9).
*   Each TAP (delayed sample) is multiplied by a constant coefficient
*   and then all products are summed using an Adder Tree (ex8).
*
********************************************************************************/

module fir_filter #(
    parameter IN_WIDTH = 8,
    parameter COEF_WIDTH = 8
)(
    input  wire clk,
    input  wire rst,
    input  wire signed [IN_WIDTH-1:0] din,
    // The multiplier width is IN_WIDTH + COEF_WIDTH.
    // The sum of 4 multiplications requires 2 extra bits (log2(4)).
    output reg  signed [IN_WIDTH + COEF_WIDTH + 1 : 0] dout
);

    localparam TAPS = 4;
    localparam MULT_WIDTH = IN_WIDTH + COEF_WIDTH;

    // Fixed filter coefficients (Could be calculated in MATLAB/Python)
    wire signed [COEF_WIDTH-1:0] h [0:3];
    assign h[0] = 8'd10;
    assign h[1] = 8'd20;
    assign h[2] = 8'd20;
    assign h[3] = 8'd10;

    // --- 1. Instantiate the Regressor (Filter Memory) ---
    wire [(IN_WIDTH * TAPS) - 1 : 0] flat_taps;
    regressor #(
        .DATA_WIDTH(IN_WIDTH),
        .TAPS(TAPS)
    ) delay_line_inst (
        .clk(clk),
        .rst(rst),
        .data_in(din),
        .flat_taps(flat_taps)
    );

    // --- 2. Combinational Multiplication ---
    // Extract the delays from the regressor
    wire signed [IN_WIDTH-1:0] tap0 = flat_taps[  IN_WIDTH-1 : 0];
    wire signed [IN_WIDTH-1:0] tap1 = flat_taps[2*IN_WIDTH-1 :   IN_WIDTH];
    wire signed [IN_WIDTH-1:0] tap2 = flat_taps[3*IN_WIDTH-1 : 2*IN_WIDTH];
    wire signed [IN_WIDTH-1:0] tap3 = flat_taps[4*IN_WIDTH-1 : 3*IN_WIDTH];

    wire signed [MULT_WIDTH-1:0] prod0 = tap0 * h[0];
    wire signed [MULT_WIDTH-1:0] prod1 = tap1 * h[1];
    wire signed [MULT_WIDTH-1:0] prod2 = tap2 * h[2];
    wire signed [MULT_WIDTH-1:0] prod3 = tap3 * h[3];

    // Pack products to send them to the adder_tree
    wire [(MULT_WIDTH * TAPS) - 1 : 0] flat_prods;
    assign flat_prods = {prod3, prod2, prod1, prod0};

    // --- 3. Adder Tree ---
    wire [MULT_WIDTH + 1 : 0] sum_wire;
    adder_tree #(
        .IN_WIDTH(MULT_WIDTH),
        .NUM_INPUTS(TAPS)
    ) sum_tree_inst (
        .flat_inputs(flat_prods),
        .sum_out(sum_wire)
    );

    // --- 4. Register Output ---
    always @(posedge clk) begin
        if (rst) begin
            dout <= 0;
        end else begin
            dout <= sum_wire; // Output pipelining
        end
    end

endmodule
