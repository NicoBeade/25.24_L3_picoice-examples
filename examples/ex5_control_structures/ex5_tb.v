`timescale 1ns/1ps
module ex5_tb;
    reg [3:0] a, b; reg [2:0] op;
    wire [3:0] res; wire zero;
    control_structures uut(.a(a), .b(b), .opcode(op), .result(res), .zero_flag(zero));
    initial begin
        $dumpvars(0, ex5_tb);
        a=4; b=2; op=0; #10; // ADD
        op=1; #10;           // SUB
        op=5; #10;           // NOT
        $finish;
    end
endmodule
