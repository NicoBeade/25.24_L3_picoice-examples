/*******************************************************************************
*                   ITBA - 25.24 Laboratorio de Electrónica III
*
* - Author: Nicolás Beade / AI Assistant
* - Description: This example demonstrates the difference between combinational 
*   logic (wire) and sequential logic (reg). 
*   
*   - wire: Continuous assignments. The value propagates immediately (with
*           hardware propagation delays).
*   - reg:  Memory elements (Flip-Flops). The value only changes on the
*           edges of the clock signal.
*
********************************************************************************/

module wire_vs_reg (
    input wire clk,
    input wire a,
    input wire b,
    output wire combinational_out,
    output reg sequential_out
);

    // Combinational Logic (Continuous assignment)
    // A change in 'a' or 'b' is reflected immediately in 'combinational_out'
    assign combinational_out = a & b;

    // Sequential Logic (always block with clock edge)
    // A change in 'a' or 'b' is only reflected in 'sequential_out' when
    // a rising edge occurs on 'clk'
    always @(posedge clk) begin
        sequential_out <= a & b;
    end

endmodule
