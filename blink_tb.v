`timescale 1ns / 1ps

module blink_tb;

    // Testbench signals
    reg ICE_SW2;
    wire LED_B;
    wire LED_G;
    wire LED_R;

    // Instantiate the module under test
    top uut (
        .LED_B(LED_B),
        .LED_G(LED_G),
        .LED_R(LED_R),
        .ICE_SW2(ICE_SW2)
    );

    // Test stimulus
    initial begin
        // Initialize
        $dumpvars(0, blink_tb);
        ICE_SW2 = 0;
        #10;

        // Test case 1: Switch off (0)
        ICE_SW2 = 0;
        #10;
        $display("Switch = 0: LED_G=%b, LED_B=%b, LED_R=%b", LED_G, LED_B, LED_R);

        // Test case 2: Switch on (1)
        ICE_SW2 = 1;
        #10;
        $display("Switch = 1: LED_G=%b, LED_B=%b, LED_R=%b", LED_G, LED_B, LED_R);

        // Test case 3: Toggle multiple times
        repeat(4) begin
            ICE_SW2 = ~ICE_SW2;
            #10;
            $display("Switch = %b: LED_G=%b, LED_B=%b, LED_R=%b", ICE_SW2, LED_G, LED_B, LED_R);
        end

        // Finish simulation
        #10;
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | ICE_SW2=%b | LED_G=%b | LED_B=%b | LED_R=%b", 
                 $time, ICE_SW2, LED_G, LED_B, LED_R);
    end

endmodule
