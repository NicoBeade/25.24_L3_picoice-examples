/*******************************************************************************
*                   ITBA - 25.24 Laboratorio de Electrónica III
*
* - Author: Nicolás Beade / AI Assistant
* - Description: Shows the most common ways to reduce word width in DSP systems.
*
*   When discarding LSBs (Fractional part):
*   - Truncation: Simply discard the LSBs. Introduces a DC bias (always rounds down).
*   - Rounding (Half-up): Add the MSB of the discarded portion to the kept portion.
*
*   When discarding MSBs (Integer part):
*   - Saturation: If the value exceeds the maximum/minimum representable by the 
*     new smaller width, it is capped at the max/min instead of wrapping around.
*
********************************************************************************/

module trunc_round_sat #(
    parameter IN_WIDTH  = 16,
    parameter OUT_WIDTH = 8
)(
    input  wire signed [IN_WIDTH-1:0]  data_in,
    
    // Outputs for discarding LSBs (Fractional reduction)
    output wire signed [OUT_WIDTH-1:0] data_trunc,
    output wire signed [OUT_WIDTH-1:0] data_round,
    
    // Outputs for discarding MSBs (Integer reduction)
    output reg  signed [OUT_WIDTH-1:0] data_sat
);

    // ==========================================
    // 1 & 2. Truncation & Rounding (Discard LSBs)
    // ==========================================
    localparam DISCARD_LSBS = IN_WIDTH - OUT_WIDTH;

    // 1. Truncation: Simply take the most significant bits (MSBs)
    assign data_trunc = data_in[IN_WIDTH-1 : DISCARD_LSBS];

    // 2. Rounding:
    // To round, we observe the most significant bit of the bits we are going to discard.
    // If that bit is 1, we add 1 to the truncated result.
    // In Verilog, we can achieve this by adding a 1 at the position of the MSB to discard.
    wire signed [IN_WIDTH-1:0] round_add;
    wire signed [IN_WIDTH-1:0] rounded_full;

    // Create the value to add the "half bit" of the position to discard.
    // Example: If we discard 8 bits, we add 1 << 7 (0x0080).
    assign round_add = 1'b1 << (DISCARD_LSBS - 1);
    
    // Perform the addition
    assign rounded_full = data_in + round_add;

    // Truncate the final sum
    assign data_round = rounded_full[IN_WIDTH-1 : DISCARD_LSBS];


    // ==========================================
    // 3. Saturation (Discard MSBs)
    // ==========================================
    // Maximum and minimum representable values for the target OUT_WIDTH
    // Max positive: 0111...1
    // Min negative: 1000...0
    localparam signed [OUT_WIDTH-1:0] MAX_VAL = {1'b0, {(OUT_WIDTH-1){1'b1}}};
    localparam signed [OUT_WIDTH-1:0] MIN_VAL = {1'b1, {(OUT_WIDTH-1){1'b0}}};

    always @* begin
        if (data_in > MAX_VAL) begin
            // Overflow: Cap at maximum positive value
            data_sat = MAX_VAL;
        end else if (data_in < MIN_VAL) begin
            // Underflow: Cap at minimum negative value
            data_sat = MIN_VAL;
        end else begin
            // Within range: Simply keep the lower bits
            data_sat = data_in[OUT_WIDTH-1:0];
        end
    end

endmodule
