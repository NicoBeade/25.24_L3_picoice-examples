`timescale 1ns/1ps
module ex4_tb;
    reg [7:0] din;
    wire [7:0] dout;
    for_loop_example uut(.data_in(din), .data_out_reversed(dout));
    initial begin
        $dumpvars(0, ex4_tb);
        din = 8'b10100011; #10;
        din = 8'b11110000; #10;
        $finish;
    end
endmodule
