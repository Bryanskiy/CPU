module controller(
    input logic[(`WORD - 1):0] instr,

    output logic[(`REG_SIZE - 1):0] rs1, rs2, rd,
    output logic regWrite, memWrite, ALUSrc,
    output logic[(`ALU_CONTROL_SIZE - 1):0] ALUControl,
    output logic[(`WORD - 1):0] imm32
);
    // control
    logic[6:0] opcode = instr[6:0];
    logic[2:0] func3 = instr[14:12];

    // registers
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd  = instr[11:7]; 

    logic[(`WORD - 1):0] i_imm32, u_imm32;
    assign i_imm32 = {{20{instr[31]}}, instr[31:20]};
    assign u_imm32 = {instr[31:12], 12'b0};

    always_comb
        case (opcode)
            `OPCODE_LOAD: begin
                regWrite = 1;
                memWrite = 0;
                ALUControl = `ALU_ADD;
                imm32 = i_imm32;
                ALUSrc = 1;
            end

            `OPCODE_STORE: begin
                regWrite = 0;
                memWrite = 1;
                ALUControl = `ALU_ADD;
                imm32 = i_imm32;
                ALUSrc = 1;     
            end

            `OPCODE_OP_IMM: begin
                case(func3)
                `INSTR_ADDI: begin
                    regWrite = 1;
                    memWrite = 0;
                    ALUControl = `ALU_ADD;
                    imm32 = i_imm32;
                    ALUSrc = 1;
                end
                default: begin assert(0); end
                endcase
            end

            `OPCODE_OP: begin
                case(func3)
                    `INSTR_ADD: begin
                        regWrite = 1;
                        memWrite = 0;
                        ALUControl = `ALU_ADD;
                        ALUSrc = 0;         
                    end
                default: begin assert(0); end
                endcase
            end

            `OPCODE_LUI: begin
                regWrite = 1;
                memWrite = 0;
                imm32 = u_imm32;
                ALUSrc = 1;
            end

            `OPCODE_SYSTEM: begin
                logic[24:0] systemInstr = instr[31:7];
                case (systemInstr)
                    `INSTR_ECALL: begin end
                    default: begin assert(0); end
                endcase
                    
            end

            default: begin assert(0); end
        endcase
 
endmodule