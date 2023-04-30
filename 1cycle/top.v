`include "consts.v"

module top(
    input logic clk
);
    logic[(`WORD-1):0] pc /*verilator public*/;
    logic[(`WORD-1):0] instr;
    logic[(`WORD-1):0] readData;
    logic[(`WORD-1):0] ALUResult /*verilator public*/;
    logic[(`WORD-1):0] writeData /*verilator public*/;
    logic memWrite /*verilator public*/;
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
        .address((ALUResult >> 2) - `DMEM_OFFSET),
        .wdata(writeData),
        .readData(readData)
    );

endmodule