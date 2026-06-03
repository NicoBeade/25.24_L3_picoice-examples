// ============================================================
// i2c_adc.v — Bit-bang I2C master for ADS1115 ADC
// Target: iCE40 (pico-ice), 12 MHz system clock
//
// Wiring (pico-ice):
//   SDA  → GPIO pin (open-drain, add 4.7 kΩ pull-up to 3.3 V)
//   SCL  → GPIO pin (open-drain, add 4.7 kΩ pull-up to 3.3 V)
//
// Operation:
//   1. Writes config register to start a single-shot conversion
//   2. Reads the conversion register and outputs 16-bit result
//   3. Pulses `valid` for one clock cycle when data is ready
// ============================================================

module i2c_adc #(
    parameter CLK_FREQ  = 12_000_000,   // 12 MHz
    parameter I2C_FREQ  =    100_000,   // 100 kHz standard mode
    parameter ADS_ADDR  = 7'h48        // ADDR pin → GND
)(
    input  wire        clk,
    input  wire        rst_n,

    // I2C bus (open-drain — drive low or tristate)
    output wire        scl_oe,   // 1 = drive SCL low
    output wire        sda_oe,   // 1 = drive SDA low
    input  wire        sda_in,   // read SDA from pin

    // Result
    output reg  [15:0] adc_data,
    output reg         valid     // pulses 1 clk when adc_data is fresh
);

// ── Clock divider ────────────────────────────────────────────
localparam HALF_PERIOD = CLK_FREQ / (2 * I2C_FREQ); // ticks per half-SCL

reg [$clog2(HALF_PERIOD)-1:0] clk_cnt;
reg                            tick;   // one pulse per half SCL period

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clk_cnt <= 0; tick <= 0;
    end else if (clk_cnt == HALF_PERIOD - 1) begin
        clk_cnt <= 0; tick <= 1;
    end else begin
        clk_cnt <= clk_cnt + 1; tick <= 0;
    end
end

// ── FSM states ───────────────────────────────────────────────
localparam [4:0]
    S_IDLE        = 0,
    S_START       = 1,
    S_ADDR_W      = 2,   // send 7-bit addr + W bit
    S_ACK_AW      = 3,
    S_REG_ADDR    = 4,   // send register pointer (0x01 = config)
    S_ACK_RA      = 5,
    S_CFG_HI      = 6,   // send config byte high
    S_ACK_CH      = 7,
    S_CFG_LO      = 8,   // send config byte low
    S_ACK_CL      = 9,
    S_STOP1       = 10,
    S_WAIT        = 11,  // wait ~9 ms for conversion
    S_START2      = 12,
    S_ADDR_W2     = 13,
    S_ACK_AW2     = 14,
    S_REG_CNV     = 15,  // point to conversion register (0x00)
    S_ACK_RC      = 16,
    S_REP_START   = 17,
    S_ADDR_R      = 18,  // addr + R bit
    S_ACK_AR      = 19,
    S_READ_HI     = 20,
    S_ACK_RH      = 21,  // master ACK
    S_READ_LO     = 22,
    S_NACK_RL     = 23,  // master NACK (last byte)
    S_STOP2       = 24,
    S_DONE        = 25;

reg [4:0] state;
reg [2:0] bit_idx;    // counts 7..0 during byte TX/RX
reg [7:0] shift;      // TX shift register
reg [7:0] rx_hi, rx_lo;
reg       scl_r, sda_r;
reg [19:0] wait_cnt;  // for conversion wait

// ADS1115 config: single-shot, AIN0/GND, ±4.096 V, 128 SPS
// 0xC3 0x83  →  1100_0011  1000_0011
localparam [7:0] CFG_HI = 8'hC3;
localparam [7:0] CFG_LO = 8'h83;

assign scl_oe = ~scl_r;   // low = drive SCL low
assign sda_oe = ~sda_r;   // low = drive SDA low

// ── Main FSM (advances on tick) ──────────────────────────────
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state   <= S_IDLE;
        scl_r   <= 1; sda_r <= 1;
        valid   <= 0; adc_data <= 0;
        bit_idx <= 7; wait_cnt <= 0;
    end else begin
        valid <= 0;
        if (tick) begin
            case (state)
            // ─── IDLE ──────────────────────────────────────
            S_IDLE: begin
                scl_r <= 1; sda_r <= 1;
                state <= S_START;
            end

            // ─── START condition (SDA falls while SCL high) ─
            S_START: begin
                sda_r <= 0; // pull SDA low
                state <= S_ADDR_W;
                shift <= {ADS_ADDR, 1'b0}; // W=0
                bit_idx <= 7;
            end

            // ─── Generic byte transmit (reused via shift) ───
            S_ADDR_W, S_REG_ADDR, S_CFG_HI, S_CFG_LO,
            S_ADDR_W2, S_REG_CNV, S_ADDR_R: begin
                // Toggle SCL; on falling edge shift out next bit
                scl_r <= ~scl_r;
                if (!scl_r) begin  // SCL going high → present bit
                    sda_r <= shift[7];
                end else begin     // SCL going low  → shift
                    if (bit_idx == 0) begin
                        sda_r <= 1; // release for ACK
                        case (state)
                        S_ADDR_W:  state <= S_ACK_AW;
                        S_REG_ADDR:state <= S_ACK_RA;
                        S_CFG_HI:  state <= S_ACK_CH;
                        S_CFG_LO:  state <= S_ACK_CL;
                        S_ADDR_W2: state <= S_ACK_AW2;
                        S_REG_CNV: state <= S_ACK_RC;
                        S_ADDR_R:  state <= S_ACK_AR;
                        endcase
                    end else begin
                        shift   <= {shift[6:0], 1'b0};
                        bit_idx <= bit_idx - 1;
                    end
                end
            end

            // ─── ACK slots (just clock one bit) ─────────────
            S_ACK_AW, S_ACK_RA, S_ACK_CH, S_ACK_CL,
            S_ACK_AW2, S_ACK_AR: begin
                scl_r <= ~scl_r;
                if (scl_r) begin  // SCL falling after ACK
                    case (state)
                    S_ACK_AW:  begin shift <= 8'h01; bit_idx<=7; state<=S_REG_ADDR; end
                    S_ACK_RA:  begin shift <= CFG_HI; bit_idx<=7; state<=S_CFG_HI;  end
                    S_ACK_CH:  begin shift <= CFG_LO; bit_idx<=7; state<=S_CFG_LO;  end
                    S_ACK_CL:  state <= S_STOP1;
                    S_ACK_AW2: begin shift <= 8'h00; bit_idx<=7; state<=S_REG_CNV; end
                    S_ACK_AR:  begin bit_idx<=7; state<=S_READ_HI; scl_r<=0; end
                    endcase
                end
            end

            S_ACK_RC: begin
                scl_r <= ~scl_r;
                if (scl_r) state <= S_REP_START;
            end

            // ─── STOP after config write ─────────────────────
            S_STOP1: begin
                sda_r <= 0; scl_r <= 1; // SCL high, then SDA rises
                state <= S_WAIT;
                wait_cnt <= 0;
            end

            // ─── Wait ~9 ms (ADS1115 128 SPS) ────────────────
            S_WAIT: begin
                // at 100 kHz tick rate, 9 ms ≈ 900 half-periods
                wait_cnt <= wait_cnt + 1;
                if (wait_cnt == 900) begin
                    sda_r <= 1;
                    state <= S_START2;
                end
            end

            // ─── Second START (read back) ─────────────────────
            S_START2: begin
                sda_r <= 0;
                state <= S_ADDR_W2;
                shift <= {ADS_ADDR, 1'b0};
                bit_idx <= 7;
            end

            // ─── Repeated START ───────────────────────────────
            S_REP_START: begin
                sda_r <= 1; scl_r <= 1;  // SCL high
                state <= S_ADDR_R;
                sda_r <= 0;              // SDA falls = repeated start
                shift <= {ADS_ADDR, 1'b1}; // R=1
                bit_idx <= 7;
                scl_r <= 0;
            end

            // ─── Receive high byte ────────────────────────────
            S_READ_HI: begin
                scl_r <= ~scl_r;
                if (!scl_r) begin   // SCL rising → sample
                    rx_hi <= {rx_hi[6:0], sda_in};
                end else if (bit_idx == 0) begin
                    state   <= S_ACK_RH;
                    bit_idx <= 7;
                end else begin
                    bit_idx <= bit_idx - 1;
                end
            end

            S_ACK_RH: begin  // send ACK (pull SDA low)
                sda_r <= 0;
                scl_r <= ~scl_r;
                if (scl_r) begin sda_r<=1; state<=S_READ_LO; end
            end

            // ─── Receive low byte ─────────────────────────────
            S_READ_LO: begin
                scl_r <= ~scl_r;
                if (!scl_r) begin
                    rx_lo <= {rx_lo[6:0], sda_in};
                end else if (bit_idx == 0) begin
                    state   <= S_NACK_RL;
                    bit_idx <= 7;
                end else begin
                    bit_idx <= bit_idx - 1;
                end
            end

            S_NACK_RL: begin  // send NACK (leave SDA high)
                sda_r <= 1;
                scl_r <= ~scl_r;
                if (scl_r) state <= S_STOP2;
            end

            // ─── STOP, latch result ───────────────────────────
            S_STOP2: begin
                sda_r <= 0; scl_r <= 1;
                adc_data <= {rx_hi, rx_lo};
                valid    <= 1;
                state    <= S_IDLE;   // restart conversion loop
            end

            default: state <= S_IDLE;
            endcase
        end
    end
end

endmodule
