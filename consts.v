`define WORD 32

typedef enum logic[6:0] {
    LOAD   = 7'b0000011,
    STORE  = 7'b0100011,
    SYSTEM = 7'b1110011,
    OP_IMM = 7'b0010011,
    OP     = 7'b0110011,
    LUI    = 7'b0110111
} OPCODES;

typedef enum bit[24:0] {
    ECALL = 'b0
} SYSTEM_INSTRS;

typedef enum bit[2:0] {
    ADDI = 'b0
} OP_IMM_FUNC3;

typedef enum bit[2:0] {
    ADD = 'b0
} OP_FUNC3;