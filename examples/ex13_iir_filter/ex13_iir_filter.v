/*******************************************************************************
*                   ITBA - 25.24 Laboratorio de Electrónica III
*
* - Author: Nicolás Beade / AI Assistant
* - Description: Infinite Impulse Response (IIR) Filter.
*   Implementation of a Simple Low-Pass Filter (Exponential Moving Average).
*   Equation: y[n] = alpha * x[n] + (1 - alpha) * y[n-1]
*   
*   To facilitate FPGA implementation (avoiding large multipliers), 
*   we choose alpha = 1/4. Thus:
*   y[n] = (1/4)*x[n] + (3/4)*y[n-1]
*   y[n] = y[n-1] + (1/4)*(x[n] - y[n-1]) -> This requires only add and shift (>> 2).
*
********************************************************************************/

module iir_filter #(
    parameter DATA_WIDTH = 16
)(
    input  wire clk,
    input  wire rst,
    input  wire signed [DATA_WIDTH-1:0] din,
    output reg  signed [DATA_WIDTH-1:0] dout
);

    wire signed [DATA_WIDTH-1:0] diff;
    wire signed [DATA_WIDTH-1:0] alpha_diff;

    // x[n] - y[n-1]
    assign diff = din - dout;

    // (x[n] - y[n-1]) * (1/4) -> Arithmetic shift right by 2
    // In Verilog, the arithmetic shift >>> preserves the sign if the type is signed.
    assign alpha_diff = diff >>> 2; 

    always @(posedge clk) begin
        if (rst) begin
            dout <= 0;
        end else begin
            // y[n] = y[n-1] + alpha * (x[n] - y[n-1])
            dout <= dout + alpha_diff;
        end
    end

endmodule
