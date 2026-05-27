`timescale 1ns/1ps

/*******************************************************************************
*                   ITBA - 25.24 Laboratorio de Electrónica III
*
* - Author: Nicolás Beade / AI Assistant
* - Description: Template for a generic Vector Matching Testbench.
*   It uses $readmemb / $readmemh to read input stimuli and expected outputs 
*   from text files.
*   
*   Very useful for DSP: Process in MATLAB/Python, export vectors to txt,
*   run in Verilog, and verify they match automatically.
*
********************************************************************************/

module vector_matching_tb;

    // Parameters
    localparam VEC_LEN = 100; // Number of vectors in the files
    
    // Clock and reset signals
    reg clk;
    reg rst;

    // Signals connected to the DUT (Device Under Test)
    // Example: A filter with 8-bit input and 8-bit output
    reg  signed [7:0] din;
    wire signed [7:0] dout;
    
    // Memories to load the vectors
    reg [7:0] stimuli [0:VEC_LEN-1];
    reg [7:0] expected [0:VEC_LEN-1];

    // DUT Instance (replace with real module)
    // dummy_dut dut ( .clk(clk), .rst(rst), .in(din), .out(dout) );

    // Clock Generation (Ex: 100 MHz -> T = 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Main Testbench Process
    integer i;
    integer errors;
    
    initial begin
        // Initialize
        rst = 1;
        din = 0;
        errors = 0;

        // Load files (files must be in the same execution directory)
        // Can be binary ($readmemb) or hexadecimal ($readmemh)
        // Uncomment when files exist:
        // $readmemh("input_vectors.txt", stimuli);
        // $readmemh("expected_vectors.txt", expected);
        
        // Wait a few cycles and release reset
        #20 rst = 0;
        
        // Iterate through the vectors
        for (i = 0; i < VEC_LEN; i = i + 1) begin
            // 1. Assign stimulus
            din = stimuli[i];
            
            // 2. Wait for next rising edge so the DUT processes it
            @(posedge clk);
            
            // 3. Wait a small delta (for combinational stabilization) if needed
            #1; 

            // NOTE: If the DUT has latency (pipelines), you must compare with 
            // the expected value shifted in time (Ex: expected[i - LATENCY]).

            // 4. Verify
            /* Uncomment when DUT is instantiated:
            if (dout !== expected[i]) begin
                $display("ERROR at index %d: Expected %h, Got %h", i, expected[i], dout);
                errors = errors + 1;
            end
            */
        end
        
        // End simulation
        if (errors == 0) begin
            $display("SIMULATION SUCCESSFUL! 0 Errors.");
        end else begin
            $display("SIMULATION FAILED with %d errors.", errors);
        end
        
        $finish;
    end

endmodule
