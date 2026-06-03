// ============================================================
// top.v — pico-ice iCE40UP5K top-level
//
// CLK = 4 MHz (pico-ice default RP2040 clock output on pin 35)
//
// Loopback test: DAC outputs sawtooth ramp, ADC reads it back.
// GREEN blinking = ADC matches DAC (loopback OK)
// RED   blinking = mismatch or no ADC data (loopback broken)
//
// DAC steps every 3 s. ADC sampled at 1.5 s into each step.
// ============================================================

module top (
    input  wire CLK,        // 4 MHz from RP2040

    // I2C (ADS1115)
    output wire I2C_SCL,
    inout  wire I2C_SDA,

    // I2S (DAC)
    output wire I2S_BCLK,
    output wire I2S_LRCLK,
    output wire I2S_DIN,

    // RGB LED — active-low plain GPIO
    output wire LED_R,      // pin 41
    output wire LED_G,      // pin 39
    output wire LED_B       // pin 40
);

// ── Timing constants at 12 MHz ───────────────────────────────
localparam CLK_FREQ    = 12_000_000;
localparam HOLD_TICKS  = 36_000_000; // 3 s   @ 12 MHz (25 bits)
localparam SETTLE_TICKS = 18_000_000; // 1.5 s @ 12 MHz (24 bits)
localparam WD_TICKS    = 2_400_000;  // 200 ms @ 12 MHz (21 bits)

// I2C: 100 kHz standard mode
// ADS1115 conversion ~9 ms @ 128 SPS
localparam I2C_FREQ    =   100_000;
localparam ADS_ADDR    = 7'h48;
localparam BCLK_FREQ   =  3_000_000;  // I2S bit clock: 3 MHz (Fs = 46.875 kHz)

// Loopback tolerance: ±2048 counts (~6% FS)
localparam signed [15:0] TOLERANCE = 16'sd2048;

// ── Reset (~1 ms = 4000 ticks at 4 MHz) ─────────────────────
reg [11:0] rst_cnt = 0;
wire rst_n = rst_cnt[11];
always @(posedge CLK) if (!rst_n) rst_cnt <= rst_cnt + 1;

// ── I2C open-drain ───────────────────────────────────────────
wire scl_oe, sda_oe, sda_in;
assign I2C_SCL = scl_oe ? 1'b0 : 1'bz;
assign I2C_SDA = sda_oe ? 1'b0 : 1'bz;
assign sda_in  = I2C_SDA;

// ── ADC ──────────────────────────────────────────────────────
wire [15:0] adc_data;
wire        adc_valid;

i2c_adc #(
    .CLK_FREQ (CLK_FREQ),
    .I2C_FREQ (I2C_FREQ),
    .ADS_ADDR (ADS_ADDR)
) u_adc (
    .clk     (CLK),
    .rst_n   (rst_n),
    .scl_oe  (scl_oe),
    .sda_oe  (sda_oe),
    .sda_in  (sda_in),
    .adc_data(adc_data),
    .valid   (adc_valid)
);

// ── Period counter (3 s hold, 1.5 s settle) ─────────────────
reg [25:0] period_cnt;
reg        hold_tick;
reg        settle_tick;

always @(posedge CLK or negedge rst_n) begin
    if (!rst_n) begin
        period_cnt  <= 0;
        hold_tick   <= 0;
        settle_tick <= 0;
    end else begin
        hold_tick   <= 0;
        settle_tick <= 0;
        if (period_cnt == HOLD_TICKS - 1) begin
            period_cnt <= 0;
            hold_tick  <= 1;
        end else begin
            if (period_cnt == SETTLE_TICKS - 1)
                settle_tick <= 1;
            period_cnt <= period_cnt + 1;
        end
    end
end

// ── Fixed test values for DAC/ADC loopback debugging ────────
// Use fixed pattern to test if DAC → ADC path works
wire [15:0] dac_value = 16'h7FFF;  // Fixed mid-range value

// ── DAC ──────────────────────────────────────────────────────
wire sample_req;

i2s_dac #(
    .CLK_FREQ  (CLK_FREQ),
    .BCLK_FREQ (BCLK_FREQ)
) u_dac (
    .clk       (CLK),
    .rst_n     (rst_n),
    .left_in   (dac_value),
    .right_in  (dac_value),
    .sample_req(sample_req),
    .bclk      (I2S_BCLK),
    .lrclk     (I2S_LRCLK),
    .dout      (I2S_DIN)
);

// ── Loopback check ───────────────────────────────────────────
reg        check_armed;
reg        last_pass;
reg        loopback_ok;

always @(posedge CLK or negedge rst_n) begin
    if (!rst_n) begin
        check_armed <= 0;
        last_pass   <= 0;
        loopback_ok <= 0;
    end else begin
        if (settle_tick)
            check_armed <= 1;

        if (adc_valid && check_armed) begin
            check_armed <= 0;
            begin : chk
                reg signed [16:0] diff;
                diff = $signed({1'b0, adc_data}) - {dac_value[15], dac_value};
                if (diff < 0) diff = -diff;
                if (diff <= {1'b0, TOLERANCE}) begin
                    loopback_ok <= last_pass;
                    last_pass   <= 1;
                end else begin
                    loopback_ok <= 0;
                    last_pass   <= 0;
                end
            end
        end
    end
end

// ── Watchdog — go red if no adc_valid for 200 ms ─────────────
reg [19:0] wd_cnt;
reg        adc_alive;

always @(posedge CLK or negedge rst_n) begin
    if (!rst_n) begin
        wd_cnt    <= 0;
        adc_alive <= 0;
    end else if (adc_valid) begin
        wd_cnt    <= 0;
        adc_alive <= 1;
    end else if (wd_cnt == WD_TICKS - 1) begin
        wd_cnt    <= 0;
        adc_alive <= 0;
    end else begin
        wd_cnt <= wd_cnt + 1;
    end
end

// Combined status: need both ADC alive and loopback match
wire ok = adc_alive & loopback_ok;

// ── Blink at ~1.4 Hz (bit 21 of 22-bit counter @ 4 MHz) ─────
reg [21:0] blink_cnt;
always @(posedge CLK) blink_cnt <= blink_cnt + 1;
wire blink = blink_cnt[21];

// ── LED — active-low ─────────────────────────────────────────
assign LED_G = ok ? ~blink : 1'b1;
assign LED_R = ok ? 1'b1   : ~blink;
assign LED_B = 1'b1;

endmodule