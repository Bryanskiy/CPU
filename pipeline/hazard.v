module hazard(
    /* for bypass */
    input logic[(`REG_SIZE - 1):0] raddr1E, raddr2E, raddr1D, raddr2D,
    input logic[(`REG_SIZE - 1):0] writeRegE, writeRegM, writeRegW,
    input logic regWriteM, regWriteW, mem2regE, controllchangeD, mem2regM,

    output logic stallF, stallD, flushE, flushD,
    output logic[1:0] forward1E, forward2E, forward1D, forward2D 
);

    /* bypasses */
    forvard forvard1(
        .raddr(raddr1E), .writeRegM(writeRegM), .writeRegW(writeRegW),
        .regWriteM(regWriteM), .regWriteW(regWriteW),
        .forward(forward1E)
    );

    forvard forvard2(
        .raddr(raddr2E), .writeRegM(writeRegM), .writeRegW(writeRegW),
        .regWriteM(regWriteM), .regWriteW(regWriteW),
        .forward(forward2E)
    );

    forvard forvard3(
        .raddr(raddr1D), .writeRegM(writeRegM), .writeRegW(writeRegW),
        .regWriteM(regWriteM), .regWriteW(regWriteW),
        .forward(forward1D)
    );

    forvard forvard4(
        .raddr(raddr2D), .writeRegM(writeRegM), .writeRegW(writeRegW),
        .regWriteM(regWriteM), .regWriteW(regWriteW),
        .forward(forward2D)
    );

    logic lwstall;
    assign lwstall = mem2regE && ((writeRegE == raddr1D) || (writeRegE == raddr2D));
    assign stallF = lwstall;
    assign stallD = lwstall;
    assign flushE = lwstall;
    assign flushD = controllchangeD;
endmodule

module forvard(
    input logic[(`REG_SIZE - 1):0] raddr, writeRegM, writeRegW,
    input logic regWriteM, regWriteW,

    output logic[1:0] forward
);
    assign forward = ((raddr != 0) & (raddr == writeRegM) & regWriteM) ? `FORWARD_M : 
                     ((raddr != 0) & (raddr == writeRegW) & regWriteW) ? `FORWARD_W :
                     `FORWARD_N;
endmodule

module forwardSrcController(
    input logic[(`WORD - 1):0] src1, src2, src3,
    input logic[1:0] forward,
    input logic validM, validW,

    output logic[(`WORD - 1):0] forwardsrc
);

    assign forwardsrc = ((forward == `FORWARD_M) & validM)? src1 :
                        ((forward == `FORWARD_W) & validW)? src2 :
                        src3;

endmodule;
