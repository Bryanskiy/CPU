module datapath(
    input logic clk,
    input logic regWrite, memWrite, mem2reg,
    input logic[(`ALU_SRC_SIZE -1):0] ALUSrc1, ALUSrc2,
    input logic[(`REG_SIZE - 1):0] rs1, rs2, rd,
    input logic[(`ALU_CONTROL_SIZE - 1):0] ALUControl,
    input logic[(`WORD - 1):0] readData,
    input logic[(`WORD - 1):0] imm32,
    input logic[1:0] pcnControl,

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

    npccontroller npccontroller(
        .pc(pc),
        .imm32(imm32),
        .pcnControl(pcnControl),
        .zero(zero),
        .rs1(rdata1),
        .pcn(pcn)
    );

    /* register file logic */
    logic[(`WORD - 1):0] rdata1, rdata2;
    logic[(`WORD - 1):0] result = mem2reg ? readData : ALUResult;

    regfile regfile(
        .clk(clk),
        .raddr1(rs1),
        .raddr2(rs2),
        .raddr3(rd),
        .wdata(result),
        .regWrite(regWrite),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    /* ALU logic */
    assign writeData = rdata2;
    logic[(`WORD - 1):0] src1, src2;
    alucontroller alucontroller(
        .ALUSrc1(ALUSrc1),
        .ALUSrc2(ALUSrc2),
        .rs1(rdata1),
        .rs2(rdata2),
        .pc(pc),
        .imm32(imm32),
        .src1(src1), 
        .src2(src2)        
    );

    alu alu(
        .src1(src1), 
        .src2(src2), 
        .ALUControl(ALUControl), 
        .ALUResult(ALUResult), 
        .zero(zero));
endmodule