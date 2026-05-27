# PICO-ICE: Entorno e Instalación


### Extensiones de VS Code
Formato: https://marketplace.visualstudio.com/items?itemName=mshr-h.VerilogHDL
Apio:    https://marketplace.visualstudio.com/items?itemName=fpgawars.apio


### Guía Básica
- apio.ini tiene información de la placa que usan y el top module. No deberían cambiarlo. 
- El módulo principal que usen llámenlo top por cuestiones de prolijidad así no tienen que cambiar apio.ini
- El archivo llámenlo como quieran, el compilador ve los nombres de los módulos nada más
- En .pcf tienen las definiciones de todos los pines con aliases, son todos de 1b.

## DSP and FPGA Beginner Examples (`examples/` Folder)

This repository includes a series of incremental examples designed to learn hardware design, with a final focus on Digital Signal Processing (DSP) on FPGA. The examples are designed to be synthesized with `apio` (which underneath uses Yosys and NextPNR for the iCE40 architecture).

**1. Verilog Basics and Syntax**
- `ex1_led_switch.v`: Basic usage of input and output pins, turning on LEDs with switches.
- `ex2_clock.v`: Usage of the internal oscillator (HFOSC) and clock dividers. (Includes comments about PLL).
- `ex3_wire_vs_reg.v`: Conceptual difference between combinational logic (`wire`) and sequential logic/registers (`reg`).
- `ex4_for_loop.v`: How to unroll logic using `for` loops inside combinational `always` blocks.
- `ex5_control_structures.v`: Usage of `if/else` and `case` to implement multiplexers and simple state machines.

**2. DSP Primitives**
- `ex6_trunc_round.v`: Bit-width reduction via truncation vs. rounding. Also includes saturation logic to prevent overflow wrapping.
- `ex8_adder_tree.v`: Parameterizable adder tree using `generate` blocks. Automatically calculates bit growth (`log2(N)`).
- `ex9_regressor.v`: Tapped delay line (shift register) that stores samples in parallel, fundamental for filters.

**3. Full DSP Applications**
- `ex10_fir_filter.v`: Finite Impulse Response (FIR) filter that instantiates the regressor (`ex9`) and multiplies samples by coefficients.
- `ex11_mac.v`: Multiply-Accumulate (MAC) block, the main engine of most DSP algorithms.
- `ex12_sine_lut.v`: Sine wave generator based on a Look-Up Table (simple DDS) using FPGA memory.
- `ex13_iir_filter.v`: Simple IIR filter example (exponential moving average low-pass filter) showing feedback.

**4. Verification and Testing**
- `ex7_vector_matching_tb.v`: Generic testbench template. Allows loading input and expected output vectors from text files (`$readmemb`/`$readmemh`) and automatically verifying the operation.

### Notes on the Examples
To synthesize and test one of the examples, make sure to instantiate it in your `top` module or configure `apio.ini` to point to the example module as the "top-module". All designs are compatible with the pico-ice board (Lattice iCE40UP5K).