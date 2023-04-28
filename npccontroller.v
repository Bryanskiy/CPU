module npccontroller(
    input logic[(`WORD - 1):0] pc, imm32, rs1,
    input logic[1:0] pcnControl,
    input logic zero,

    output logic[(`WORD - 1):0] pcn
);
    logic[(`WORD - 1):0] pcPlus4, pcPlusImm, pcJalr;
    assign pcPlus4 = pc + 4;
    assign pcPlusImm = pc + imm32;
    assign pcJalr = rs1 + imm32;

    always_comb
        case(pcnControl)
            `ALU_NPC_4:       pcn = pcPlus4;
            `ALU_NPC_BRANCH:  pcn = zero ? pcPlusImm : pcPlus4;
            `ALU_NPC_JAL:     pcn = pcPlusImm;
            `ALU_NPC_JALR:    pcn = {pcJalr[31:1], 1'b0};
        endcase
endmodule