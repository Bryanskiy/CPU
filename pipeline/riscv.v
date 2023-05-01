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
        .mem2regE(mem2regE)
    );

/*=======================================================================
                                EXECUTE
=========================================================================*/
    logic[(`WORD - 1):0] writeDataM, ALUResultM, pcM;
    logic[(`REG_SIZE - 1):0] writeRegM;
    logic zeroM;
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

        .writeDataM(writeDataM), 
        .writeRegM(writeRegM), 
        .ALUResultM(ALUResultM), 
        .pcM(pcM),
        .zeroM(zeroM)
    );

endmodule