`include "consts.v"

module riscv(
    input logic clk, reset
);
/*=======================================================================
                                FETCH
=========================================================================*/
    logic[(`WORD-1):0] pcD, instrD;
    fetch fetch(
        .clk(clk),
        .reset(reset),
        .pcD(pcD),
        .instrD(instrD)
    );
/*=======================================================================
                                DECODE
=========================================================================*/
    logic[(`WORD - 1):0] rdata1E, rdata2E, immE, pcE;
    logic[(`REG_SIZE - 1):0] writeRegE;
    logic[3:0] ALUControlE;
    logic[1:0] ALUSrcE;
    logic regWriteE, memWriteE, mem2regE;
    logic branchE;

    logic regWriteW;
    logic[(`WORD-1):0] resultW;
    decode decode(
        .clk(clk),
        .reset(reset),
        .pcD(pcD),
        .instrD(instrD),
        .regWriteW(regWriteW),
        .resultW(resultW),
        .rdata1E(rdata1E),
        .rdata2E(rdata2E),
        .writeRegE(writeRegE),
        .immE(immE),
        .pcE(pcE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .regWriteE(regWriteE),
        .memWriteE(memWriteE),
        .mem2regE(mem2regE),
        .branchE(branchE)
    );

/*=======================================================================
                                EXECUTE
=========================================================================*/
    logic[(`WORD - 1):0] writeDataM, ALUResultM, pcM;
    logic[(`REG_SIZE - 1):0] writeRegM;
    logic regWriteM, memWriteM, mem2regM;
    logic zeroM, branchM;
    execute execute(
        .clk(clk),
        .reset(reset),
        .rdata1E(rdata1E), 
        .rdata2E(rdata2E), 
        .immE(immE), 
        .pcE(pcE),
        .writeRegE(writeRegE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .regWriteE(regWriteE), 
        .memWriteE(memWriteE), 
        .mem2regE(mem2regE),
        .branchE(branchE),

        .writeDataM(writeDataM), 
        .writeRegM(writeRegM), 
        .ALUResultM(ALUResultM), 
        .pcM(pcM),
        .regWriteM(regWriteM),
        .memWriteM(memWriteM),
        .mem2regM(mem2regM),
        .branchM(branchM),
        .zeroM(zeroM)
    );

/*=======================================================================
                                MEMORY
=========================================================================*/
    logic[(`WORD - 1):0] readDataW, ALUResultW;
    logic[(`REG_SIZE - 1):0] writeRegW;
    logic mem2regW;
    logic PCSrcM;
    memory memory(
        .clk(clk),
        .reset(reset),
        .writeDataM(writeDataM), 
        .ALUResultM(ALUResultM),
        .pcM(pcM),
        .writeRegM(writeRegM),
        .regWriteM(regWriteM),
        .memWriteM(regWriteM),
        .mem2regM(regWriteM),
        .zeroM(zeroM),
        .branchM(branchM),

        .readDataW(readDataW),
        .ALUResultW(ALUResultW),
        .writeRegW(writeRegW),
        .regWriteW(regWriteW),
        .mem2regW(mem2regW),
        .PCSrcM(PCSrcM)
    );

endmodule