/*******************************************************************************
*                   ITBA - 25.24 Laboratorio de Electrónica III
*
* - Author: Nicolás Beade / AI Assistant
* - Description: Sine Look-Up Table (LUT) or Direct Digital Synthesis (DDS).
*   Generates a pre-calculated sine wave. The phase acts as an 
*   accumulator that addresses the ROM table.
*
*   ROM values should be generated from Python/MATLAB and loaded into Verilog.
*   Here we assume a ROM synthesized via combinational always blocks 
*   or $readmemh initializing an internal memory.
*
********************************************************************************/

module sine_lut #(
    parameter PHASE_WIDTH = 8, // 256 samples for a full cycle
    parameter DATA_WIDTH  = 8
)(
    input  wire clk,
    input  wire rst,
    input  wire [PHASE_WIDTH-1:0] phase_inc, // Frequency (phase increment)
    output reg signed [DATA_WIDTH-1:0] sine_out
);

    // Phase accumulator
    reg [PHASE_WIDTH-1:0] phase_acc;

    always @(posedge clk) begin
        if (rst) begin
            phase_acc <= 0;
        end else begin
            phase_acc <= phase_acc + phase_inc;
        end
    end

    // LUT: We assume a 16-position wave for simplicity of the example.
    // In a real case, this would be a RAM initialized with $readmemh.
    always @(posedge clk) begin
        // Using the 4 most significant bits of the accumulator to address 16 positions.
        case (phase_acc[PHASE_WIDTH-1 : PHASE_WIDTH-4])
            4'd0:  sine_out <=  8'd0;
            4'd1:  sine_out <=  8'd49;
            4'd2:  sine_out <=  8'd90;
            4'd3:  sine_out <=  8'd117;
            4'd4:  sine_out <=  8'd127;
            4'd5:  sine_out <=  8'd117;
            4'd6:  sine_out <=  8'd90;
            4'd7:  sine_out <=  8'd49;
            4'd8:  sine_out <=  8'd0;
            4'd9:  sine_out <= -8'd49;
            4'd10: sine_out <= -8'd90;
            4'd11: sine_out <= -8'd117;
            4'd12: sine_out <= -8'd127;
            4'd13: sine_out <= -8'd117;
            4'd14: sine_out <= -8'd90;
            4'd15: sine_out <= -8'd49;
            default: sine_out <= 8'd0;
        endcase
    end

endmodule
