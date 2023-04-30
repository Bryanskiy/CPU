module fetch
#(parameter IMEM_POWER = 18)
(
    input logic clk, reset,

    output logic[(`WORD-1):0] pcPlus4, instrD
);
    /* next pc logic */
    logic[(`WORD-1):0] pc /*verilator public*/, npc;
    initial assign npc = pc;

    flopr pcreg(.clk(clk), .reset(reset), .d(npc), .q(pc));
    assign npc = pc + 4;

    /* instruction memory */
    reg[(`WORD - 1):0] RAM[0:((1 << IMEM_POWER) - 1)] /*verilator public*/;
    logic[(`WORD-1):0] instr = RAM[pc >> 2];

    /* fetch register */
    logic[(2 * `WORD-1):0] fetchregd, fetchregq;
    assign fetchregd = {pc + 4, instr};
    flopr #(.WIDTH(2 * `WORD)) fetchreg(.clk(clk), .reset(reset), .d(fetchregd), .q(fetchregq));

    /* return values for DECODE stage */
    assign pcPlus4 = fetchregq[(2 * `WORD-1):`WORD];
    assign instrD  = fetchregq[(`WORD - 1):0];
endmodule