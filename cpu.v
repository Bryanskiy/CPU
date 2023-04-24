module cpu(
    input logic clk,
    input logic[(`WORD - 1):0] instr,
    input logic[(`WORD - 1):0] readData,

    output logic[(`WORD - 1):0] pc,
    output logic[(`WORD - 1):0] ALUResult, writeData,
    output logic memWrite,
    output logic finish
);
    logic regWrite, ALUSrc;
    logic[(`REG_SIZE - 1):0] rs1, rs2, rd;
    logic[(`ALU_CONTROL_SIZE - 1):0] ALUControl;
    logic[(`WORD - 1):0] imm32;

    controller controller(
        .instr(instr), 
        .regWrite(regWrite), 
        .memWrite(memWrite),
        .ALUSrc(ALUSrc),
        .rs1(rs1),
        .rs2(rs2), 
        .rd(rd), 
        .ALUControl(ALUControl),
        .imm32(imm32),
        .finish(finish)
    );

    datapath datapath(
        .clk(clk),
        .regWrite(regWrite),
        .memWrite(memWrite),
        .ALUSrc(ALUSrc),
        .readData(readData),
        .imm32(imm32),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .ALUControl(ALUControl),
        .pc(pc),
        .ALUResult(ALUResult));
endmodule