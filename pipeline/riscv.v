`include "consts.v"

module riscv(
    input logic clk, reset
);
    /* fetch stage */
    logic[(`WORD-1):0] pcD, pcM, instrD;
    logic PCSrcM;
    logic validD;
    fetch fetch(
        .clk(clk),
        .reset(reset),
        .pcM(pcM),
        .PCSrcM(PCSrcM),

        .pcD(pcD),
        .instrD(instrD),
        .validD(validD)
    );

    /* decode +  wb */
    logic[(`WORD - 1):0] rdata1E, rdata2E, immE, pcE;
    logic[(`REG_SIZE - 1):0] writeRegE;
    logic[3:0] ALUControlE;
    logic[1:0] ALUSrcE;
    logic regWriteE, memWriteE, mem2regE;
    logic branchE;
    logic finishE, validE;

    logic regWriteW;
    logic[(`WORD-1):0] resultW;
    decode decode(
        .clk(clk),
        .reset(reset),
        .pcD(pcD),
        .instrD(instrD),
        .regWriteW(regWriteW),
        .resultW(resultW),
        .validD(validD),

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
        .branchE(branchE),
        .finishE(finishE),
        .validE(validE)
    );

    /* execute stage */
    logic[(`WORD - 1):0] writeDataM, ALUResultM;
    logic[(`REG_SIZE - 1):0] writeRegM;
    logic regWriteM, memWriteM, mem2regM;
    logic zeroM, branchM;
    logic finishM, validM;
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
        .finishE(finishE),
        .validE(validE),

        .writeDataM(writeDataM), 
        .writeRegM(writeRegM), 
        .ALUResultM(ALUResultM), 
        .pcM(pcM),
        .regWriteM(regWriteM),
        .memWriteM(memWriteM),
        .mem2regM(mem2regM),
        .branchM(branchM),
        .zeroM(zeroM),
        .finishM(finishM),
        .validM(validM)
    );

    /* memory stage */
    logic[(`WORD - 1):0] readDataW, ALUResultW;
    logic[(`REG_SIZE - 1):0] writeRegW;
    logic mem2regW, memWriteW;
    logic finishW, validW;
    memory memory(
        .clk(clk),
        .reset(reset),
        .writeDataM(writeDataM), 
        .ALUResultM(ALUResultM),
        .writeRegM(writeRegM),
        .regWriteM(regWriteM),
        .memWriteM(regWriteM),
        .mem2regM(regWriteM),
        .zeroM(zeroM),
        .branchM(branchM),
        .finishM(finishM),
        .validM(validM),

        .readDataW(readDataW),
        .ALUResultW(ALUResultW),
        .writeRegW(writeRegW),
        .regWriteW(regWriteW),
        .mem2regW(mem2regW),
        .memWriteW(memWriteW),
        .PCSrcM(PCSrcM),
        .finishW(finishW),
        .validW(validW)
    );

    assign resultW = mem2regW ? readDataW : ALUResultW;

    /* trace */
    logic[31:0] num;
    always @(negedge clk) begin
        num <= num + 1;
        $display("-----------------------");
        $display("NUM=%0d", num);

        if (regWriteW & (writeRegW != 0))
            $display("x%0d=0x%0h", writeRegW, resultW);
        else if (memWriteW)
            $display("M[0x%0h]=0x%0h", ALUResultW, writeDataM);
        
        $display("PC=0x%0h", pcD);
        if (finishW)
            $finish;
    end

endmodule