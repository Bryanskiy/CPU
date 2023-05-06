module fetch
#(parameter IMEM_POWER = 18)
(
    input logic clk, reset, en,
    input logic PCSrcM,
    input logic[(`WORD-1):0] pcM,

    output logic[(`WORD-1):0] pcD, instrD,
    output logic validD
);
    /* next pc logic */
    logic[(`WORD-1):0] pc /*verilator public*/, npc;

    flopr pcreg(.clk(clk), .reset(reset), .d(npc), .q(pc));
    assign npc = PCSrcM ? pcM : pc + 4;

    /* instruction memory */
    reg[(`WORD - 1):0] RAM[0:((1 << IMEM_POWER) - 1)] /*verilator public*/;
    logic[(`WORD-1):0] instr = RAM[pc >> 2];

    /* fetch register */
    logic[(2 * `WORD):0] fetchregd, fetchregq;
    assign fetchregd = {pc, instr, npc != 0};
    initial assign fetchregq = fetchregd;
    flopr #(.WIDTH(2 * `WORD + 1)) fetchreg(
        .clk(clk),
        .reset(reset),
        .en(en),
        .d(fetchregd),
        .q(fetchregq)
    );

    /* return values for DECODE stage */
    assign {pcD, instrD, validD} = fetchregq;
endmodule