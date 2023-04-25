module alu(
    input logic[(`WORD - 1):0] src1, src2,
    input logic[(`ALU_CONTROL_SIZE - 1):0] ALUControl,

    output logic[(`WORD - 1):0] ALUResult,
    output logic zero
);
    always_comb begin
        case(ALUControl)
            `ALU_ADD: ALUResult = src1 + src2;
            `ALU_SLT: ALUResult = {{31{1'b0}}, $signed(src1) >= $signed(src2)};
            default: begin assert(0); end
        endcase
        zero = (ALUResult == 0);
    end

endmodule