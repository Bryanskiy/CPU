module cpu(
    input logic clk,
    input logic [(`WORD - 1):0] instr,
    output logic [(`WORD - 1):0] pc
);
    logic regWrite, memWrite;
    controller controller(instr, regWrite, memWrite);

endmodule