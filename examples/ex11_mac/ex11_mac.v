/*******************************************************************************
*                   ITBA - 25.24 Laboratorio de Electrónica III
*
* - Author: Nicolás Beade / AI Assistant
* - Description: Multiply-Accumulate (MAC). 
*   Main DSP operation: Out = Out + (A * B).
*   Uses inferred logic that Yosys will map to embedded DSP blocks 
*   (MAC16) in the iCE40UP5K if parameters are appropriate.
*
********************************************************************************/

module mac #(
    parameter A_WIDTH = 16,
    parameter B_WIDTH = 16,
    parameter ACC_WIDTH = 32
)(
    input  wire clk,
    input  wire rst,
    input  wire clr,     // Clear the accumulator (to process a new block)
    input  wire signed [A_WIDTH-1:0] a,
    input  wire signed [B_WIDTH-1:0] b,
    output reg  signed [ACC_WIDTH-1:0] acc
);

    // It is important to register the multiplication so that Yosys/NextPNR 
    // can use the embedded registers of the MAC16 block and achieve higher fmax.
    reg signed [A_WIDTH+B_WIDTH-1:0] mult_reg;

    always @(posedge clk) begin
        if (rst) begin
            mult_reg <= 0;
            acc <= 0;
        end else begin
            // 1. Multiplication Stage
            mult_reg <= a * b;

            // 2. Accumulation Stage
            if (clr) begin
                acc <= mult_reg; // If there is a clear, load initial mult_reg value
            end else begin
                acc <= acc + mult_reg;
            end
        end
    end

endmodule
