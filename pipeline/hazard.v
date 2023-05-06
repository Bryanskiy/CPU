module hazard(
    /* for bypass */
    input logic[(`REG_SIZE - 1):0] raddr1E, raddr2E, 
    input logic[(`REG_SIZE - 1):0] writeRegM, writeRegW,
    input logic regWriteM, regWriteW,

    output logic[1:0] forward1, forward2
);

    /* bypasses */
    forvard forvard1(
        .raddrE(raddr1E), .writeRegM(writeRegM), .writeRegW(writeRegW),
        .regWriteM(regWriteM), .regWriteW(regWriteW),
        .forward(forward1)
    );

    forvard forvard2(
        .raddrE(raddr2E), .writeRegM(writeRegM), .writeRegW(writeRegW),
        .regWriteM(regWriteM), .regWriteW(regWriteW),
        .forward(forward2)
    );

endmodule

module forvard(
    input logic[(`REG_SIZE - 1):0] raddrE, writeRegM, writeRegW,
    input logic regWriteM, regWriteW,

    output logic[1:0] forward
);
    assign forward = ((raddrE != 0) & (raddrE == writeRegM) & regWriteM) ? `FORWARD_M : 
                     ((raddrE != 0) & (raddrE == writeRegW) & regWriteW) ? `FORWARD_W :
                     `FORWARD_N;
endmodule