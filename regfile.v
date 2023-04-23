module regfile(
    input logic[(`REG_SIZE - 1):0] raddr1, raddr2, raddr3,
    input logic[(`WORD - 1):0] wdata,
    input logic regWrite,

    output logic[(`WORD - 1):0] rdata1, rdata2
);
    logic[(`WORD - 1):0] GRF[(`REG_COUNT - 1):0];

    // write to GRF
    /* verilator lint_off LATCH */ always_comb begin
        if (regWrite != 0) begin
            assign GRF[raddr3] = wdata;
        end
    end
    // read from GRF
    assign rdata1 = (raddr1 != 0) ? GRF[raddr1] : 0;
    assign rdata2 = (raddr2 != 0) ? GRF[raddr2] : 0;
endmodule