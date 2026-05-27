/*******************************************************************************
*                   ITBA - 25.24 Laboratorio de Electrónica III
*
* - Author: Nicolás Beade / AI Assistant
* - Description: Example of common control structures: if/else and case.
*   In this example, a small ALU (Arithmetic Logic Unit) is implemented.
*
********************************************************************************/

module control_structures (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [2:0] opcode,
    output reg  [3:0] result,
    output reg        zero_flag
);

    // Operation Codes (OpCodes) using local parameters (constants)
    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_AND = 3'b010;
    localparam OP_OR  = 3'b011;
    localparam OP_XOR = 3'b100;
    localparam OP_NOT = 3'b101; // NOT of 'a'

    // Combinational Logic (ALU)
    always @* begin
        // Use of CASE to multiplex operations
        case (opcode)
            OP_ADD: result = a + b;
            OP_SUB: result = a - b;
            OP_AND: result = a & b;
            OP_OR:  result = a | b;
            OP_XOR: result = a ^ b;
            OP_NOT: result = ~a;
            default: result = 4'b0000; // Always define a default value
        endcase

        // Use of IF/ELSE to set flags
        if (result == 4'b0000) begin
            zero_flag = 1'b1;
        end else begin
            zero_flag = 1'b0;
        end
    end

endmodule
