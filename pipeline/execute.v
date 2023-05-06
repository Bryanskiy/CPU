module execute(
    input logic clk, reset,
    input logic[(`WORD - 1):0] rdata1E, rdata2E, immE, pcE,
    input logic[(`REG_SIZE - 1):0] writeRegE,    
    input logic[3:0] ALUControlE,
    input logic[1:0] ALUSrcE,
    input logic regWriteE, memWriteE, mem2regE,
    input logic branchE,
    input logic finishE, validE,

    output logic[(`WORD - 1):0] writeDataM, ALUResultM, pcM,
    output logic[(`REG_SIZE - 1):0] writeRegM,
    output logic regWriteM, memWriteM, mem2regM,
    output logic zeroM, branchM, finishM, validM
);

    logic[(`WORD - 1):0] src1, src2;

    /* calculate alu input */
    alucontroller alucontroller(
        .ALUSrc(ALUSrcE),
        .rs1(rdata1E),
        .rs2(rdata2E),
        .pc(pcE),
        .imm32(immE),
        .src1(src1), 
        .src2(src2)        
    );

    logic[(`WORD - 1):0] writeDataE = rdata2E;
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

    flopr #(.WIDTH(EXEC_REG_SIZE)) execreg(.clk(clk), .reset(reset), .d(execregd), .q(execregq));

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
    input logic[(`WORD - 1):0] imm32, rs1, rs2, pc,
    input logic[1:0] ALUSrc,

    output logic[(`WORD - 1):0] src1, src2
);

    always_comb
        case(ALUSrc)
            `ALU_SRC_IMM: begin
                src1 = rs1;
                src2 = imm32;
            end

            `ALU_SRC_RD2: begin
                src1 = rs1;
                src2 = rs2;
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