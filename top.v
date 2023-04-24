`include "consts.v"

module top(
    input logic clk
);
    logic[(`WORD-1):0] pc /*verilator public*/;
    logic[(`WORD-1):0] instr;
    logic[(`WORD-1):0] readData, writeData, ALUResult;
    logic memWrite;
    logic finish /*verilator public*/;

    initial assign finish = 0;

    imem imem(pc, instr);

    cpu cpu(
        .clk(clk), 
        .instr(instr), 
        .pc(pc),
        .readData(readData),
        .writeData(writeData),
        .ALUResult(ALUResult),
        .memWrite(memWrite),
        .finish(finish));

    dmem dmem(
        .clk(clk),
        .memWrite(memWrite),
        .address(ALUResult),
        .wdata(writeData),
        .readData(readData)
    );

endmodule