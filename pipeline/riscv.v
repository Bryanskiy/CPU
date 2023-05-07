`include "consts.v"

module riscv(
    input logic clk, reset
);
    logic stallF, stallD, flushE, flushD;
    /* fetch stage */
    logic[(`WORD-1):0] pcD, pcM, instrD, pcnD;
    logic PCSrcD;
    logic validD;
    fetch fetch(
        .clk(clk),
        .reset(flushD),
        .en(!stallD),
        .stallF(stallF),
        .pcnD(pcnD),
        .PCSrcD(controllchangeD),

        .pcD(pcD),
        .instrD(instrD),
        .validD(validD)
    );

    /* decode +  wb */
    logic[(`WORD - 1):0] rdata1E, rdata2E, immE, pcE;
    logic[(`REG_SIZE - 1):0] writeRegE, raddr1E, raddr2E, raddr1D, raddr2D;
    logic[3:0] ALUControlE;
    logic[1:0] ALUSrcE, ALUnpcE;
    logic regWriteE, memWriteE, mem2regE, controllchangeD;
    logic finishE, validE;

    logic regWriteW;
    logic[(`WORD-1):0] resultW;
    logic[1:0] forward1D, forward2D;
    decode decode(
        .clk(clk),
        .reset(flushE),
        .en(1),
        .pcD(pcD),
        .instrD(instrD),
        .regWriteW(regWriteW),
        .resultW(resultW),
        .validD(validD),
        .forward1(forward1D),
        .forward2(forward2D),
        .validM(validM),
        .validW(validW),
        .ALUResultM(ALUResultM),

        .controllchangeD(controllchangeD),
        .pcnD(pcnD),
        .rdata1E(rdata1E),
        .rdata2E(rdata2E),
        .raddr1E(raddr1E),
        .raddr2E(raddr2E),
        .raddr1D(raddr1D),
        .raddr2D(raddr2D),
        .writeRegE(writeRegE),
        .writeRegM(writeRegM),
        .immE(immE),
        .pcE(pcE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .regWriteE(regWriteE),
        .memWriteE(memWriteE),
        .mem2regE(mem2regE),
        .finishE(finishE),
        .validE(validE)
    );

    /* execute stage */
    logic[(`WORD - 1):0] writeDataM, ALUResultM;
    logic[(`REG_SIZE - 1):0] writeRegM;
    logic regWriteM, memWriteM, mem2regM;
    logic finishM, validM;

    logic[1:0] forward1E, forward2E;
    execute execute(
        .clk(clk),
        .reset(reset),
        .en(1),
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
        .finishE(finishE),
        .validE(validE),
        .forward1(forward1E),
        .forward2(forward2E),
        .resultW(resultW),
        .validW(validW),

        .writeDataM(writeDataM), 
        .writeRegM(writeRegM), 
        .ALUResultM(ALUResultM), 
        .pcM(pcM),
        .regWriteM(regWriteM),
        .memWriteM(memWriteM),
        .mem2regM(mem2regM),
        .finishM(finishM),
        .validM(validM)
    );

    /* memory stage */
    logic[(`WORD - 1):0] readDataW, ALUResultW, pcW, writeDataW;
    logic[(`REG_SIZE - 1):0] writeRegW;
    logic mem2regW, memWriteW;
    logic finishW, validW;
    memory memory(
        .clk(clk),
        .reset(reset),
        .en(1),
        .writeDataM(writeDataM), 
        .ALUResultM(ALUResultM),
        .writeRegM(writeRegM),
        .regWriteM(regWriteM),
        .memWriteM(memWriteM),
        .mem2regM(mem2regM),
        .finishM(finishM),
        .validM(validM),
        .pcM(pcM),

        .readDataW(readDataW),
        .ALUResultW(ALUResultW),
        .writeRegW(writeRegW),
        .writeDataW(writeDataW),
        .pcW(pcW),
        .regWriteW(regWriteW),
        .mem2regW(mem2regW),
        .memWriteW(memWriteW),
        .finishW(finishW),
        .validW(validW)
    );

    assign resultW = mem2regW ? readDataW : ALUResultW;

    /* hazard */
    hazard hazard(
        .raddr1E(raddr1E),
        .raddr2E(raddr2E),
        .writeRegM(writeRegM),
        .writeRegW(writeRegW),
        .regWriteM(regWriteM),
        .regWriteW(regWriteW),
        .mem2regE(mem2regE),
        .raddr1D(raddr1D),
        .raddr2D(raddr2D),
        .writeRegE(writeRegE),
        .controllchangeD(controllchangeD),
        .mem2regM(mem2regM),

        .stallF(stallF),
        .stallD(stallD),
        .flushE(flushE),
        .flushD(flushD),
        .forward1E(forward1E),
        .forward2E(forward2E),
        .forward1D(forward1D),
        .forward2D(forward2D)
    );

    /* trace */
    logic[31:0] num = 1;
    always @(negedge clk) begin
        if (validW) begin
            num <= num + 1;
            $display("-----------------------");
            $display("NUM=%0d", num);

            if (regWriteW & (writeRegW != 0))
                $display("x%0d=0x%0h", writeRegW, resultW);
            else if (memWriteW)
                $display("M[0x%0h]=0x%0h", ALUResultW, writeDataW);
        
            /* TODO: better npc */
            $display("PC=0x%0h", pcW + 4);
        end
        if (finishW)
            $finish;
    end

endmodule