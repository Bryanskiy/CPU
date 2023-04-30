module cpu(
    input logic clk,
    input logic[(`WORD - 1):0] instr,
    input logic[(`WORD - 1):0] readData,

    output logic[(`WORD - 1):0] pc,
    output logic[(`WORD - 1):0] ALUResult, writeData,
    output logic memWrite,
    output logic finish
);
    logic regWrite /*verilator public*/, mem2reg;
    logic[(`ALU_SRC_SIZE - 1):0] ALUSrc1, ALUSrc2;
    logic[(`REG_SIZE - 1):0] rs1, rs2, rd  /*verilator public*/;
    logic[(`ALU_CONTROL_SIZE - 1):0] ALUControl;
    logic[(`WORD - 1):0] imm32;
    logic[1:0] pcnControl;

    controller controller(
        .instr(instr), 
        .regWrite(regWrite), 
        .memWrite(memWrite),
        .pcnControl(pcnControl),
        .ALUSrc1(ALUSrc1),
        .ALUSrc2(ALUSrc2),       
        .mem2reg(mem2reg),
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
        .pcnControl(pcnControl),
        .ALUSrc1(ALUSrc1),
        .ALUSrc2(ALUSrc2),        
        .mem2reg(mem2reg),
        .readData(readData),
        .imm32(imm32),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .ALUControl(ALUControl),
        .pc(pc),
        .writeData(writeData),
        .ALUResult(ALUResult));
endmodule