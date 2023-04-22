module controller(
    input logic [(`WORD - 1):0] instr,
    output logic regWrite,
    output logic memWrite
);
    // control
    logic[6:0] opcode = instr[6:0];
    logic[2:0] func3 = instr[14:12];

    // registers
    logic[4:0] rs1 = instr[19:15];

    always_comb
        case (opcode)
            LOAD: begin
                regWrite = 1;
                memWrite = 0;
            end

            STORE: begin
                regWrite = 0;
                memWrite = 1;                
            end

            OP_IMM: begin
                case(func3)
                ADDI: begin
                    regWrite = 1;
                    memWrite = 0;
                end
                default: begin assert(0); end
                endcase
            end

            OP: begin
                case(func3)
                    ADD: begin
                        regWrite = 1;
                        memWrite = 0;                        
                    end
                default: begin assert(0); end
                endcase
            end

            LUI: begin
                regWrite = 1;
                memWrite = 0;
            end

            SYSTEM: begin
                logic[24:0] systemInstr = instr[31:7];
                case (systemInstr)
                    ECALL: begin end
                    default: begin assert(0); end
                endcase
                    
            end

            default: begin assert(0); end
        endcase
 
endmodule