/*******************************************************************************
*                   ITBA - 25.24 Laboratorio de Electrónica III
*
* - Author: Nicolás Beade / AI Assistant
* - Description: Implementation of an Adder Tree.
*   In DSP, to sum N samples, instead of chaining adders (which creates a long 
*   critical path and limits the max frequency), a tree structure is used 
*   (log2(N) stages).
*   
*   This example shows how to calculate the bit width based on the number 
*   of elements. (Each sum requires 1 extra bit).
*
********************************************************************************/

module adder_tree #(
    parameter IN_WIDTH = 8,
    parameter NUM_INPUTS = 4 // For simplicity, we assume powers of 2 (Ex: 4, 8, 16)
)(
    // We flatten the input array because passing 2D arrays via ports 
    // is not always supported by all standard Verilog tools.
    input  wire [(IN_WIDTH * NUM_INPUTS) - 1 : 0] flat_inputs,
    // Output width will be IN_WIDTH + log2(NUM_INPUTS)
    output wire [IN_WIDTH + $clog2(NUM_INPUTS) - 1 : 0] sum_out
);

    // Calculated parameter: log2(NUM_INPUTS)
    localparam LOG2_N = $clog2(NUM_INPUTS);
    localparam OUT_WIDTH = IN_WIDTH + LOG2_N;

    // Array to organize the flattened input
    wire signed [IN_WIDTH-1:0] inputs [0:NUM_INPUTS-1];

    genvar i;
    generate
        for (i = 0; i < NUM_INPUTS; i = i + 1) begin : unpack
            assign inputs[i] = flat_inputs[(i+1)*IN_WIDTH - 1 : i*IN_WIDTH];
        end
    endgenerate

    // Logic for a 4-Input Adder Tree specifically.
    // Creating a fully generic tree in Verilog requires complex recursive 
    // constructs or 3D arrays. Here we show the expansion for N=4.
    
    // Stage 1 (2 sums) -> Grows by 1 bit
    wire signed [IN_WIDTH:0] stage1_sum0;
    wire signed [IN_WIDTH:0] stage1_sum1;
    
    assign stage1_sum0 = inputs[0] + inputs[1];
    assign stage1_sum1 = inputs[2] + inputs[3];

    // Stage 2 (1 final sum) -> Grows by another bit
    wire signed [IN_WIDTH+1:0] final_sum;
    assign final_sum = stage1_sum0 + stage1_sum1;

    // Assign output
    assign sum_out = final_sum;

endmodule
