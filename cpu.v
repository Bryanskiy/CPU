module cpu(
    input logic clk,
    input logic [(`WORD - 1):0] instr,
    output logic [(`WORD - 1):0] pc
);
    logic regWrite, memWrite;
    logic [3:0] ALUControl;
    controller controller(instr, regWrite, memWrite, ALUControl);
    datapath datapath(clk, regWrite, memWrite, ALUControl);

endmodule