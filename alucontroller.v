module alucontroller(
    input logic[(`ALU_SRC_SIZE -1):0] ALUSrc1, ALUSrc2,
    input logic[(`WORD - 1):0] imm32, rs1, rs2, pc,

    output logic[(`WORD - 1):0] src1, src2
);

    always_comb
        case(ALUSrc2)
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
            default: begin assert(0); end
    endcase
endmodule