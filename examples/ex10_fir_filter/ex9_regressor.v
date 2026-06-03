/*******************************************************************************
*                   ITBA - 25.24 Laboratorio de Electrónica III
*
* - Author: Nicolás Beade / AI Assistant
* - Description: Delay Line (Regressor or Tapped Delay Line).
*   On each clock cycle, it shifts the data, keeping a history of the 
*   previous samples. It is the fundamental memory block for FIR digital filters.
*
********************************************************************************/

module regressor #(
    parameter DATA_WIDTH = 8,
    parameter TAPS = 4 // Number of samples kept in history
)(
    input  wire clk,
    input  wire rst,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    // Flat output to facilitate portability.
    // It will have a width of DATA_WIDTH * TAPS
    output wire [(DATA_WIDTH * TAPS) - 1 : 0] flat_taps
);

    // Memory for the delays
    reg signed [DATA_WIDTH-1:0] delay_line [0:TAPS-1];

    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < TAPS; i = i + 1) begin
                delay_line[i] <= 0;
            end
        end else begin
            // Shift samples: The highest index (oldest) receives the previous one
            for (i = TAPS-1; i > 0; i = i - 1) begin
                delay_line[i] <= delay_line[i-1];
            end
            // Position 0 (newest) receives the input data
            delay_line[0] <= data_in;
        end
    end

    // Pack the memory positions into the flat output
    genvar j;
    generate
        for (j = 0; j < TAPS; j = j + 1) begin : pack
            assign flat_taps[(j+1)*DATA_WIDTH - 1 : j*DATA_WIDTH] = delay_line[j];
        end
    endgenerate

endmodule
