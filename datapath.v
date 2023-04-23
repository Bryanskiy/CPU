module datapath(
    input logic clk,
    input logic regWrite,
    input logic memWrite,
    input logic[(`REG_SIZE - 1):0] rs1, rs2, rd,
    input logic[(`ALU_CONTROL_SIZE - 1):0] ALUControl,

    output logic[(`WORD - 1):0] pc,
    output logic[(`WORD - 1):0] ALUResult
);
    logic[(`WORD - 1):0] pcn;
    logic zero;
    /* next PC logic */
    flopr pcreg(.clk(clk), .reset(0), .d(pcn), .q(pc)); // TODO: add reset
    assign pcn = pc + `WORD; // TODO: jums

    logic[(`WORD - 1):0] src1, src2;
    logic[(`WORD - 1):0] wdata;
    /* register file logic */
    regfile regfile(
        .raddr1(rs1),
        .raddr2(rs2),
        .raddr3(rd),
        .wdata(wdata),
        .regWrite(regWrite),
        .rdata1(src1),
        .rdata2(src2)
    );

    /* ALU logic */
    alu alu(src1, src2, ALUControl, ALUResult, zero);
endmodule