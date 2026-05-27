

/*******************************************************************************
*                   ITBA - 25.24 Laboratorio de Electrónica III
*
* - Author: Nicolás Beade / AI Assistant
* - Based on examples from pico-ice.tinyvision.ai
* - Description: This is a simple example to demonstrate clock usage and division.
*   The high-frequency oscillator (HFOSC) runs at 48 MHz, which is too fast for
*   visible blinking. We divide it down to about 1.4 Hz using a simple counter.
*
*           - "0b00" → 48 MHz
*           - "0b01" → 24 MHz  
*           - "0b10" → 12 MHz  ← good default
*           - "0b11" →  6 MHz
********************************************************************************/

module clock_divider (
    output LED_B,
    output LED_G,
    output LED_R,
    output ICE_31,
    input  ICE_SW2
);

  // --- High-frequency oscillator (HFOSC): 48 MHz ---
  wire clk_hf;
  SB_HFOSC #(.CLKHF_DIV("0b10")) u_hfosc (  // "0b10" = 12 MHz, "0b00" = 48 MHz
    .CLKHFEN(1'b1),
    .CLKHFPU(1'b1),
    .CLKHF(clk_hf)
  );

  // --- Divide 12 MHz down to ~1.4 Hz for visible blinking ---
  reg [22:0] divider;

  always @(posedge clk_hf) begin
    divider <= divider + 1;
  end

  wire slow_clk = divider[22];  // 12MHz / 2^23 ≈ 1.4 Hz

  // Active-low LEDs on pico-ice
  assign LED_R = ICE_SW2;       // Follows switch (active-low)
  assign LED_G = ~slow_clk;     // Blinks
  assign LED_B =  slow_clk;     // Blinks opposite phase

  // High-speed clock out for scope
  assign ICE_31 = clk_hf;

endmodule