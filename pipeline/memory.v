module memory
#(parameter DMEM_POWER = 18)
(
    input logic clk, reset,
    input logic[(`WORD - 1):0] writeDataM, ALUResultM,
    input logic[(`REG_SIZE - 1):0] writeRegM,
    input logic regWriteM, memWriteM, mem2regM,
    input logic zeroM, branchM,
    input logic finishM,

    output logic[(`WORD - 1):0] readDataW, ALUResultW,
    output logic[(`REG_SIZE - 1):0] writeRegW,
    output logic regWriteW, mem2regW, memWriteW,
    output logic PCSrcM,
    output logic finishW
);
    /* memory read/write */
    reg[(`WORD - 1):0] RAM[0 :((1 << DMEM_POWER) - 1)];
    logic[(`WORD - 1):0] address = ALUResultM >> 2;
    always_ff @(posedge clk) begin
        if (memWriteM) RAM[address] <= writeDataM;
    end
    logic[(`WORD - 1):0] readDataM = RAM[address];

    /* memory register */
    localparam MEM_REG_SIZE = 2 * `WORD + `REG_SIZE + 4; // size of output module params 
    logic[(MEM_REG_SIZE - 1):0] memregd, memregq;
    assign memregd = {
        readDataM, ALUResultM, writeRegM, regWriteM, mem2regM, memWriteM, finishM
    };
    flopr #(.WIDTH(MEM_REG_SIZE)) fetchreg(.clk(clk), .reset(reset), .d(memregd), .q(memregq));

    /* output */
    assign PCSrcM = zeroM & branchM;
    assign {
        readDataW, ALUResultW, writeRegW, regWriteW, mem2regW, memWriteW, finishW
    } = memregq;
endmodule