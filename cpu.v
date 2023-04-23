module cpu(
    input logic clk,
    input logic [(`WORD - 1):0] instr,
    output logic [(`WORD - 1):0] pc,
    output logic [(`WORD - 1):0] ALUResult
);
    logic regWrite, memWrite;
    logic [(`REG_SIZE - 1):0] rs1, rs2, rd;
    logic [(`ALU_CONTROL_SIZE - 1):0] ALUControl;

    controller controller(
        .instr(instr), 
        .regWrite(regWrite), 
        .memWrite(memWrite), 
        .rs1(rs1),
        .rs2(rs2), 
        .rd(rd), 
        .ALUControl(ALUControl)
    );

    datapath datapath(
        .clk(clk),
        .regWrite(regWrite),
        .memWrite(memWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .ALUControl(ALUControl),
        .pc(pc),
        .ALUResult(ALUResult));
endmodule