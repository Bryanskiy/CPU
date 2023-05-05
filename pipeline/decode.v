module decode(
    input logic clk, reset,
    /* decode stage logic */
    input logic[(`WORD-1):0] pcD, instrD,
    /* write back stage logic */
    input logic regWriteW,
    input logic[(`WORD-1):0] resultW,

    output logic[(`WORD - 1):0] rdata1E, rdata2E, immE, pcE,
    output logic[(`REG_SIZE - 1):0] writeRegE,
    output logic[3:0] ALUControlE,
    output logic[1:0] ALUSrcE,
    output logic regWriteE, memWriteE, mem2regE,
    output logic branchE
);
    /* instruction decode */
    logic regWriteD, memWriteD, mem2regD;
    logic branchD;

    logic[6:0] opcode = instrD[6:0];
    logic[2:0] func3 = instrD[14:12];
    maindec maindec(
        .opcode(opcode),
        .regWrite(regWriteD),
        .memWrite(memWriteD),
        .mem2reg(mem2regD),
        .branch(branchD)
    );

    logic[3:0] ALUControlD;
    logic[1:0] ALUSrcD;
    aludec aludec(
        .opcode(opcode),
        .func3(func3),
        .ALUControl(ALUControlD),
        .ALUSrc(ALUSrcD)
    );

    logic[(`WORD-1):0] immD;
    immsel immsel(.instr(instrD), .imm(immD));

    /* regfile logic: write back + read data for exec stage */
    logic[(`REG_SIZE - 1):0] rs1, rs2, rd, writeRegD;
    assign rs1 = instrD[19:15];
    assign rs2 = instrD[24:20];
    assign rd  = instrD[11:7];
    assign writeRegD = rd;

    logic[(`WORD - 1):0] rdata1D, rdata2D;

    regfile regfile(
        .clk(clk),
        .raddr1(rs1),
        .raddr2(rs2),
        .raddr3(rd),
        .wdata(resultW),
        .regWrite(regWriteW),
        .rdata1(rdata1D),
        .rdata2(rdata2D)
    );

    /* decode register */
    localparam DECODE_REG_SIZE = 4 * `WORD + 9 + `REG_SIZE; // size of output module params 
    logic[(DECODE_REG_SIZE-1):0] decregd, decregq;
    assign decregd = {
        regWriteD,
        memWriteD,
        mem2regD,
        ALUControlD,
        ALUSrcD,
        writeRegD,
        rdata1D,
        rdata2D,
        immD,
        pcD
    };
    flopr #(.WIDTH(DECODE_REG_SIZE)) decodereg(.clk(clk), .reset(reset), .d(decregd), .q(decregq));
    
    /* output for exec stage */
    assign {
        regWriteE,
        memWriteE,
        mem2regE,
        ALUControlE,
        ALUSrcE,
        writeRegE,
        rdata1E,
        rdata2E,
        immE,
        pcE
    } = decregq;
      
endmodule

module maindec(
    input logic[6:0] opcode,

    output logic regWrite, memWrite, mem2reg,
    output logic branch
);
    always_comb
        case(opcode)
            `OPCODE_LOAD: begin
                regWrite = 1;
                memWrite = 0;
                mem2reg = 1;
                branch = 0;
            end
            `OPCODE_STORE: begin
                regWrite = 0;
                memWrite = 1;
                mem2reg = 0;
                branch = 0;
             end
            `OPCODE_SYSTEM: begin
                regWrite = 0;
                memWrite = 0;
                mem2reg = 0;
                branch = 0;
             end
            `OPCODE_OP_IMM: begin 
                regWrite = 1;
                memWrite = 0;
                mem2reg = 0;
                branch = 0;                
            end
            `OPCODE_OP: begin
                regWrite = 1;
                memWrite = 0;
                mem2reg = 0;
                branch = 0;
            end
            `OPCODE_LUI: begin
                regWrite = 1;
                memWrite = 0;
                mem2reg = 0;
                branch = 0;
            end
            `OPCODE_BRANCH: begin
                regWrite = 0;
                memWrite = 0;
                mem2reg = 0;
                branch = 1; 
            end
            `OPCODE_JAL: begin
                regWrite = 1;
                memWrite = 0;
                mem2reg = 0;
                branch = 0;
            end
            `OPCODE_JALR: begin
                regWrite = 1;
                memWrite = 0;
                mem2reg = 0;
                branch = 0;                
            end

            default: begin
                regWrite = 0;
                memWrite = 0;
                mem2reg = 0;
                branch = 0;
            end
        endcase
endmodule

module aludec(
    input logic[6:0] opcode,
    input logic[2:0] func3,

    output logic[3:0] ALUControl,
    output logic[1:0] ALUSrc
);
    always_comb
        case(opcode)
            `OPCODE_LOAD, `OPCODE_LUI, `OPCODE_STORE: begin
                ALUControl = `ALU_ADD;
                ALUSrc = `ALU_SRC_IMM;
            end

            `OPCODE_JAL, `OPCODE_JALR: begin
                ALUControl = `ALU_ADD;
                ALUSrc = `ALU_SRC_PC_PLUS_4;
            end

            `OPCODE_BRANCH: begin
                ALUSrc = `ALU_SRC_RD2;
                case (func3)
                    3'b000, 3'b001:
                        ALUControl = `ALU_SUB; // beq, bne
                    3'b100, 3'b101:
                        ALUControl = `ALU_SLT; // blt, bge
                    3'b110, 3'b111:
                        ALUControl = `ALU_SLTU; // bltu, bgeu

                    default: ALUControl = 4'bxxxx;                        
                endcase
            end

            `OPCODE_OP, `OPCODE_OP_IMM: begin
                ALUSrc = (opcode == `OPCODE_OP) ? `ALU_SRC_RD2 : `ALU_SRC_IMM; 
                case (func3)
                    3'b000: ALUControl = `ALU_ADD;

                    default: ALUControl = 4'bxxxx;
                endcase
            end
            default:
                ALUControl = 4'bxxxx;
        endcase
endmodule

module immsel(
    input logic[(`WORD - 1):0] instr,

    output logic[(`WORD - 1):0] imm    
);
    logic[6:0] opcode = instr[6:0];
    logic[2:0] func3 = instr[14:12];
    always_comb
        case(opcode)
            `OPCODE_STORE:
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type

            `OPCODE_OP_IMM, `OPCODE_LOAD, `OPCODE_JALR: 
                imm = {{20{instr[31]}}, instr[31:20]}; // I-type

            `OPCODE_LUI: imm = {instr[31:12], 12'b0}; // U-type

            `OPCODE_BRANCH:
                imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type

            `OPCODE_JAL: imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type

            default: imm = 'hx;
        endcase
endmodule

module regfile(
    input clk,
    input logic[(`REG_SIZE - 1):0] raddr1, raddr2, raddr3,
    input logic[(`WORD - 1):0] wdata,
    input logic regWrite,

    output logic[(`WORD - 1):0] rdata1, rdata2
);
    logic[(`WORD - 1):0] GRF[(`REG_COUNT - 1):0]  /*verilator public*/;

    // write to GRF
    always_ff @(negedge clk) begin
        if (regWrite != 0) begin
            GRF[raddr3] <= wdata;
        end
    end
    // read from GRF
    assign rdata1 = (raddr1 != 0) ? GRF[raddr1] : 0;
    assign rdata2 = (raddr2 != 0) ? GRF[raddr2] : 0;
endmodule