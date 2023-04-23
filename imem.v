module imem
#(parameter IMEM_POWER = 18)
(
    input logic [(`WORD - 1):0] pc,
    output logic [(`WORD - 1):0] instr
);

    reg[(`WORD - 1):0] RAM[ 0 :((1 << IMEM_POWER) - 1)] /*verilator public*/;
    assign instr = RAM[pc];

endmodule