module execute(
    input logic clk, reset, en,
    input logic[(`WORD - 1):0] rdata1E, rdata2E, immE, pcE,
    input logic[(`REG_SIZE - 1):0] writeRegE,    
    input logic[3:0] ALUControlE,
    input logic[1:0] ALUSrcE,
    input logic regWriteE, memWriteE, mem2regE,
    input logic branchE,
    input logic finishE, validE,

    /* bypass */
    input logic[1:0] forward1, forward2,
    input logic[(`WORD - 1):0] resultW,
    input logic validW,

    /* output */
    output logic[(`WORD - 1):0] writeDataM, ALUResultM, pcM, pcALUM,
    output logic[(`REG_SIZE - 1):0] writeRegM,
    output logic regWriteM, memWriteM, mem2regM,
    output logic zeroM, branchM, finishM, validM
);

    logic[(`WORD - 1):0] src1, src2;
    logic[(`WORD - 1):0] writeDataE;
    /* calculate alu input */
    alucontroller alucontroller(
        .ALUSrc(ALUSrcE),
        .rs1(rdata1E),
        .rs2(rdata2E),
        .writeDataE(writeDataE),
        .forward1(forward1),
        .forward2(forward2),
        .resultW(resultW),
        .validM(validM),
        .validW(validW),
        .ALUResultM(ALUResultM),
        .pc(pcE),
        .imm32(immE),
        .src1(src1), 
        .src2(src2)        
    );

    /* alu */
    logic[(`WORD - 1):0] ALUResultE;
    logic zeroE;
    alu alu(
        .src1(src1), 
        .src2(src2), 
        .ALUControl(ALUControlE), 
        .ALUResult(ALUResultE), 
        .zero(zeroE));

    /* execute register logic */
    localparam EXEC_REG_SIZE = 3 * `WORD + `REG_SIZE + 7; // size of output module params 
    logic[(EXEC_REG_SIZE-1):0] execregd, execregq;

    assign execregd = {
        writeDataE, ALUResultE, pcE, writeRegE, zeroE, branchE, finishE,
        regWriteE, memWriteE, mem2regE, validE
    };

    flopr #(.WIDTH(EXEC_REG_SIZE)) execreg(.clk(clk), .reset(reset), .en(en), .d(execregd), .q(execregq));

    /* ouput parameters for memory stage */
    assign {
        writeDataM, ALUResultM, pcM, writeRegM, zeroM, branchM, finishM,
        regWriteM, memWriteM, mem2regM, validM
    } = execregq;

endmodule

module alu(
    input logic[(`WORD - 1):0] src1, src2,
    input logic[3:0] ALUControl,

    output logic[(`WORD - 1):0] ALUResult,
    output logic zero
);
    always_comb begin
        case(ALUControl)
            `ALU_ADD: 
                ALUResult = src1 + src2;
            `ALU_SLT: 
                ALUResult = {{31{1'b0}}, $signed(src1) < $signed(src2)};
            default: 
                $display("invalid ALUControl: %b\n", ALUControl);
        endcase
        zero = (ALUResult == 0);
    end

endmodule

module alucontroller(
    input logic[(`WORD - 1):0] imm32, rs1, rs2, pc, ALUResultM, resultW,
    input logic[1:0] ALUSrc,
    input logic[1:0] forward1, forward2,
    input logic validM, validW,

    output logic[(`WORD - 1):0] src1, src2, writeDataE
);
    logic[(`WORD - 1):0] forwardsrc1, forwardsrc2;
    forwardSrcController forwardSrcController1(
        .ALUResultM(ALUResultM), .resultW(resultW), .src(rs1),
        .validM(validM), .validW(validW),
        .forward(forward1), .forwardsrc(forwardsrc1)
    );

    forwardSrcController forwardSrcController2(
        .ALUResultM(ALUResultM), .resultW(resultW), .src(rs2),
        .validM(validM), .validW(validW),
        .forward(forward2), .forwardsrc(forwardsrc2)
    );

    assign writeDataE = forwardsrc2;
    always_comb
        case(ALUSrc)
            `ALU_SRC_IMM: begin
                src1 = forwardsrc1;
                src2 = imm32;
            end

            `ALU_SRC_RD2: begin
                src1 = forwardsrc1;
                src2 = forwardsrc2;
            end

            `ALU_SRC_PC_PLUS_4: begin
                src2 = pc;
                src1 = 4;
            end

            default: begin
                assert(0);
            end
    endcase
endmodule

module forwardSrcController(
    input logic[(`WORD - 1):0] ALUResultM, resultW, src,
    input logic[1:0] forward,
    input logic validM, validW,

    output logic[(`WORD - 1):0] forwardsrc
);

    assign forwardsrc = ((forward == `FORWARD_M) & validM)? ALUResultM :
                        ((forward == `FORWARD_W) & validW) ? resultW :
                        src;

endmodule;