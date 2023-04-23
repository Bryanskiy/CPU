`include "consts.v"

module top(
    input logic clk
);
    logic[(`WORD-1):0] pc /*verilator public*/;
    logic[(`WORD-1):0] instr;
    logic[(`WORD-1):0] ALUResult;

    imem imem(pc, instr);
    cpu cpu(clk, instr, pc, ALUResult);

endmodule