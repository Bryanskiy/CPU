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

// instructions masks (detect instr by funct3/funct7/...)
`define INSTR_ECALL 25'b0
`define INSTR_ADDI   3'b0
`define INSTR_ADD    3'b0

/*=======================================================================
                            ALU CONSTANTS
=========================================================================*/

`define ALU_CONTROL_SIZE 4
`define ALU_ADD `ALU_CONTROL_SIZE'b0