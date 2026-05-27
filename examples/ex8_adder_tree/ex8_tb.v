`timescale 1ns/1ps
module ex8_tb;
    reg [31:0] flat_in;
    wire [9:0] sum;
    adder_tree uut(.flat_inputs(flat_in), .sum_out(sum));
    initial begin
        $dumpvars(0, ex8_tb);
        flat_in = {8'd1, 8'd2, 8'd3, 8'd4}; #10;
        $finish;
    end
endmodule
