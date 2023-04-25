module datapath(
    input logic clk,
    input logic regWrite, memWrite, ALUSrc, mem2reg,
    input logic[(`REG_SIZE - 1):0] rs1, rs2, rd,
    input logic[(`ALU_CONTROL_SIZE - 1):0] ALUControl,
    input logic[(`WORD - 1):0] readData,
    input logic[(`WORD - 1):0] imm32,

    output logic[(`WORD - 1):0] pc,
    output logic[(`WORD - 1):0] writeData,    
    output logic[(`WORD - 1):0] ALUResult
);
    /* verilator lint_off UNOPTFLAT */
    logic[(`WORD - 1):0] pcn /*verilator public*/;
    initial assign pc = pcn;

    logic zero;
    /* next PC logic */
    flopr pcreg(.clk(clk), .reset(0), .d(pcn), .q(pc));
    assign pcn = pc + 4; // TODO: jumps

    /* register file logic */
    logic[(`WORD - 1):0] src1, src2;
    logic[(`WORD - 1):0] result = mem2reg ? readData : ALUResult;

    regfile regfile(
        .clk(clk),
        .raddr1(rs1),
        .raddr2(rs2),
        .raddr3(rd),
        .wdata(result),
        .regWrite(regWrite),
        .rdata1(src1),
        .rdata2(src2)
    );

    /* ALU logic */
    assign writeData = src2;
    logic[(`WORD - 1):0] srcB = ALUSrc ? imm32 : src2;
    alu alu(
        .src1(src1), 
        .src2(srcB), 
        .ALUControl(ALUControl), 
        .ALUResult(ALUResult), 
        .zero(zero));
endmodule