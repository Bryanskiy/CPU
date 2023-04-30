module controller(
    input logic[(`WORD - 1):0] instr,

    output logic[(`REG_SIZE - 1):0] rs1, rs2, rd,
    output logic regWrite, memWrite, mem2reg,
    output logic[(`ALU_SRC_SIZE -1):0] ALUSrc1, ALUSrc2,
    output logic[(`ALU_CONTROL_SIZE - 1):0] ALUControl,
    output logic[(`WORD - 1):0] imm32,
    output logic[1:0] pcnControl,
    output logic finish
);
    // control
    logic[6:0] opcode = instr[6:0];
    logic[2:0] func3 = instr[14:12];

    // registers
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd  = instr[11:7]; 

    logic[(`WORD - 1):0] i_imm32, u_imm32, s_imm32, j_imm32, b_imm32;
    assign i_imm32 = {{20{instr[31]}}, instr[31:20]};
    assign b_imm32 = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; 
    assign u_imm32 = {instr[31:12], 12'b0};
    assign s_imm32 = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    assign j_imm32 = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

    always_comb
        case (opcode)
            `OPCODE_LOAD: begin
                regWrite = 1;
                memWrite = 0;
                ALUControl = `ALU_ADD;
                imm32 = i_imm32;
                ALUSrc2 = `ALU_SRC_IMM;
                mem2reg = 1;
                pcnControl = `ALU_NPC_4;
            end

            `OPCODE_STORE: begin
                regWrite = 0;
                memWrite = 1;
                ALUControl = `ALU_ADD;
                imm32 = s_imm32;
                ALUSrc2 = `ALU_SRC_IMM;
                pcnControl = `ALU_NPC_4;
            end

            `OPCODE_BRANCH: begin
                regWrite = 0;
                memWrite = 0;
                ALUSrc2 = `ALU_SRC_RD2;                  
                imm32 = b_imm32;
                pcnControl = `ALU_NPC_BRANCH;

                case(func3)
                    `INSTR_BLT: ALUControl = `ALU_SLT;
                    default: begin assert(0); end
                endcase

            end

            `OPCODE_JAL: begin
                regWrite = 1;
                memWrite = 0;
                imm32 = j_imm32;
                ALUControl = `ALU_ADD;
                ALUSrc2 = `ALU_SRC_PC_PLUS_4;
                ALUSrc1 = `ALU_SRC_PC;
                pcnControl = `ALU_NPC_JAL;
            end

            `OPCODE_JALR: begin
                regWrite = 1;
                memWrite = 0;
                imm32 = i_imm32;                
                ALUControl = `ALU_ADD;
                ALUSrc2 = `ALU_SRC_PC_PLUS_4;
                ALUSrc1 = `ALU_SRC_PC;
                pcnControl = `ALU_NPC_JALR;
            end

            `OPCODE_OP_IMM: begin
                mem2reg = 0;
                regWrite = 1;
                memWrite = 0;
                imm32 = i_imm32;
                ALUSrc2 = `ALU_SRC_IMM;
                pcnControl = `ALU_NPC_4;  
                case(func3)
                `INSTR_ADDI: begin
                    ALUControl = `ALU_ADD;
                end
                default: begin assert(0); end
                endcase
            end

            `OPCODE_OP: begin
                mem2reg = 0; 
                regWrite = 1;
                memWrite = 0;
                ALUSrc2 = `ALU_SRC_RD2;
                pcnControl = `ALU_NPC_4; 
                case(func3)
                    `INSTR_ADD: begin
                        ALUControl = `ALU_ADD;              
                    end
                default: begin assert(0); end
                endcase
            end

            `OPCODE_LUI: begin
                regWrite = 1;
                memWrite = 0;
                imm32 = u_imm32;
                ALUSrc2 = `ALU_SRC_IMM;
                pcnControl = `ALU_NPC_4;                
            end

            `OPCODE_SYSTEM: begin
                logic[24:0] systemInstr = instr[31:7];
                pcnControl = `ALU_NPC_4;   
                case (systemInstr)
                    `INSTR_ECALL: begin 
                        finish = 1;
                    end
                    default: begin assert(0); end
                endcase
                    
            end

            default: begin assert(0); end
        endcase
 
endmodule