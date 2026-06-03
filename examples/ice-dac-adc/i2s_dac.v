// ============================================================
// i2s_dac.v — I2S transmitter for iCE40UP5K (pico-ice)
//
// Configurable clock: BCLK_DIV calculated from CLK_FREQ and BCLK_FREQ
// Default: CLK_FREQ = 12 MHz, BCLK_FREQ = 1 MHz -> BCLK_DIV = 6
// LRCLK period = 64 BCLK cycles = 64 µs (at 1 MHz BCLK)
//
// Philips I2S: 16-bit stereo, MSB first.
// Data changes on BCLK falling edge, DAC samples on rising edge.
// LRCLK=0 left, LRCLK=1 right. 1-bit delay slot after LRCLK edge.
// ============================================================

module i2s_dac #(
    parameter CLK_FREQ  = 12_000_000,  // System clock frequency (Hz)
    parameter BCLK_FREQ =  1_000_000   // I2S bit clock frequency (Hz)
) (
    input  wire        clk,
    input  wire        rst_n,

    input  wire [15:0] left_in,
    input  wire [15:0] right_in,
    output reg         sample_req,

    output reg         bclk,
    output reg         lrclk,
    output reg         dout
);

// BCLK_DIV = CLK_FREQ / (2 * BCLK_FREQ)
// BCLK toggles every BCLK_DIV system clocks -> BCLK = CLK_FREQ / (2 * BCLK_DIV)
localparam BCLK_DIV = CLK_FREQ / (2 * BCLK_FREQ);
localparam BCLK_CNT_WIDTH = $clog2(BCLK_DIV);

reg [BCLK_CNT_WIDTH-1:0] bclk_cnt;
reg       bclk_tick;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bclk_cnt  <= 0;
        bclk_tick <= 0;
    end else if (bclk_cnt == BCLK_DIV - 1) begin
        bclk_cnt  <= 0;
        bclk_tick <= 1;
    end else begin
        bclk_cnt  <= bclk_cnt + 1;
        bclk_tick <= 0;
    end
end

// ── Bit counter and shift registers ─────────────────────────
reg [5:0]  bit_cnt;
reg [15:0] shift_l, shift_r;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bclk       <= 0;
        lrclk      <= 0;
        dout       <= 0;
        bit_cnt    <= 0;
        shift_l    <= 0;
        shift_r    <= 0;
        sample_req <= 0;
    end else begin
        sample_req <= 0;

        if (bclk_tick) begin
            bclk <= ~bclk;

            if (bclk) begin
                // ── BCLK falling edge ─────────────────────────
                bit_cnt <= bit_cnt + 1;

                // LRCLK transitions 1 BCLK before MSB (Philips I2S)
                if (bit_cnt == 6'd31) lrclk <= 1'b1;
                if (bit_cnt == 6'd63) lrclk <= 1'b0;

                case (bit_cnt)
                    // Left channel
                    6'd0: begin
                        shift_l    <= left_in;
                        shift_r    <= right_in;
                        dout       <= 1'b0;
                        sample_req <= 1'b1;
                    end
                    6'd1:  dout <= left_in[15];
                    6'd2:  dout <= shift_l[14];
                    6'd3:  dout <= shift_l[13];
                    6'd4:  dout <= shift_l[12];
                    6'd5:  dout <= shift_l[11];
                    6'd6:  dout <= shift_l[10];
                    6'd7:  dout <= shift_l[9];
                    6'd8:  dout <= shift_l[8];
                    6'd9:  dout <= shift_l[7];
                    6'd10: dout <= shift_l[6];
                    6'd11: dout <= shift_l[5];
                    6'd12: dout <= shift_l[4];
                    6'd13: dout <= shift_l[3];
                    6'd14: dout <= shift_l[2];
                    6'd15: dout <= shift_l[1];
                    6'd16: dout <= shift_l[0];
                    6'd17,6'd18,6'd19,6'd20,6'd21,6'd22,6'd23,
                    6'd24,6'd25,6'd26,6'd27,6'd28,6'd29,6'd30,
                    6'd31: dout <= 1'b0;
                    // Right channel
                    6'd32: dout <= 1'b0;
                    6'd33: dout <= shift_r[15];
                    6'd34: dout <= shift_r[14];
                    6'd35: dout <= shift_r[13];
                    6'd36: dout <= shift_r[12];
                    6'd37: dout <= shift_r[11];
                    6'd38: dout <= shift_r[10];
                    6'd39: dout <= shift_r[9];
                    6'd40: dout <= shift_r[8];
                    6'd41: dout <= shift_r[7];
                    6'd42: dout <= shift_r[6];
                    6'd43: dout <= shift_r[5];
                    6'd44: dout <= shift_r[4];
                    6'd45: dout <= shift_r[3];
                    6'd46: dout <= shift_r[2];
                    6'd47: dout <= shift_r[1];
                    6'd48: dout <= shift_r[0];
                    6'd49,6'd50,6'd51,6'd52,6'd53,6'd54,6'd55,
                    6'd56,6'd57,6'd58,6'd59,6'd60,6'd61,6'd62,
                    6'd63: dout <= 1'b0;
                    default: dout <= 1'b0;
                endcase
            end
        end
    end
end

endmodule