/*******************************************************************************
*                   ITBA - 25.24 Laboratorio de Electrónica III
*
* - Author: Nicolás Beade / AI Assistant
* - Based on examples from pico-ice.tinyvision.ai
* - Description: This is a simple example to demonstrate led and switch control.
*   You can use the switch to control and reset code you write in the next exercises.
*
********************************************************************************/

module led_switch (
    output LED_B,
    output LED_G,
    output LED_R,
    input  ICE_SW2
);

  assign LED_G = ICE_SW2;
  assign LED_B  = ~ICE_SW2;
  assign LED_R   = ICE_SW2;

endmodule