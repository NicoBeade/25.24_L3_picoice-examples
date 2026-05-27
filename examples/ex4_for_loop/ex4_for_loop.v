/*******************************************************************************
*                   ITBA - 25.24 Laboratorio de Electrónica III
*
* - Author: Nicolás Beade / AI Assistant
* - Description: This example demonstrates how to use 'for' loops in Verilog.
*   In hardware, 'for' loops DO NOT execute sequentially in time as in 
*   software (C, Python). Instead, the synthesizer "unrolls" the loop and 
*   replicates the hardware in parallel.
*   
*   A bit reversal case is shown.
*
********************************************************************************/

module for_loop_example (
    input  wire [7:0] data_in,
    output reg  [7:0] data_out_reversed
);

    integer i;

    // Combinational always block (@* is used to react to any change)
    // Even though 'reg' is used for the output, since there is no clock edge,
    // this synthesizes as pure combinational logic (crossed wires).
    always @* begin
        // It's good practice to initialize the output by default in combinational
        // blocks to avoid inferring latches.
        data_out_reversed = 8'b0;
        
        // The for loop "connects" the input bit i to the output bit (7-i).
        for (i = 0; i < 8; i = i + 1) begin
            data_out_reversed[7-i] = data_in[i];
        end
    end

endmodule
