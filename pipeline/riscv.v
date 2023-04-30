`include "consts.v"

module riscv(
    input logic clk, reset
);

    logic[(`WORD-1):0] pcPlus4, instrD;
    fetch fetch(
        .clk(clk),
        .reset(reset),
        .pcPlus4(pcPlus4),
        .instrD(instrD)
    );



endmodule