/*=======================================================================
                        GENERAL PURPOSE CONSTANTS
=========================================================================*/

`define WORD 32

`define REG_COUNT 32
`define REG_SIZE 5

`define DMEM_OFFSET 32'h3FFF0000

/*=======================================================================
                        CONTROLLER CONSTANTS
=========================================================================*/

// opcode FROM Chapter 24 RISCV spec
`define OPCODE_LOAD   7'b0000011
`define OPCODE_STORE  7'b0100011
`define OPCODE_SYSTEM 7'b1110011
`define OPCODE_OP_IMM 7'b0010011
`define OPCODE_OP     7'b0110011
`define OPCODE_LUI    7'b0110111
`define OPCODE_JAL    7'b1101111
`define OPCODE_BRANCH 7'b1100011

// instructions masks (detect instr by funct3/funct7/...)
`define INSTR_ECALL 25'b0

`define INSTR_ADDI   3'b0
`define INSTR_ADD    3'b0

`define INSTR_BEQ    3'b000
`define INSTR_BNE    3'b001
`define INSTR_BLT    3'b100
`define INSTR_BGE    3'b101
`define INSTR_BLTU   3'b110
`define INSTR_BGEU   3'b111

/*=======================================================================
                            ALU CONSTANTS
=========================================================================*/

`define ALU_CONTROL_SIZE 4

`define ALU_SRC_SIZE 2
`define ALU_SRC_RD2       2'b00
`define ALU_SRC_IMM       2'b01
`define ALU_SRC_PC        2'b10
`define ALU_SRC_PC_PLUS_4 2'b11

`define ALU_NPC_4         2'b00
`define ALU_NPC_BRANCH    2'b11
`define ALU_NPC_JAL       2'b01
`define ALU_NPC_JALR      2'b10

`define ALU_ADD `ALU_CONTROL_SIZE'b0
`define ALU_SLT `ALU_CONTROL_SIZE'b1