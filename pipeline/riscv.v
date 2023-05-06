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
    logic[(`REG_SIZE - 1):0] writeRegE, raddr1E, raddr2E;
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
        .raddr1E(raddr1E),
        .raddr2E(raddr2E),
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
    logic[(`WORD - 1):0] writeDataM, ALUResultM, pcALUM;
    logic[(`REG_SIZE - 1):0] writeRegM;
    logic regWriteM, memWriteM, mem2regM;
    logic zeroM, branchM;
    logic finishM, validM;

    logic[1:0] forward1, forward2;
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
        .forward1(forward1),
        .forward2(forward2),
        .resultW(resultW),
        .validW(validW),

        .writeDataM(writeDataM), 
        .writeRegM(writeRegM), 
        .ALUResultM(ALUResultM), 
        .pcM(pcM),
        .pcALUM(pcALUM),
        .regWriteM(regWriteM),
        .memWriteM(memWriteM),
        .mem2regM(mem2regM),
        .branchM(branchM),
        .zeroM(zeroM),
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
        .writeDataM(writeDataM), 
        .ALUResultM(ALUResultM),
        .writeRegM(writeRegM),
        .regWriteM(regWriteM),
        .memWriteM(memWriteM),
        .mem2regM(mem2regM),
        .zeroM(zeroM),
        .branchM(branchM),
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
        .PCSrcM(PCSrcM),
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

        .forward1(forward1),
        .forward2(forward2)
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