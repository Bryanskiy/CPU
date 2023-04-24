module dmem
#(parameter DMEM_POWER = 30)
(
    input logic clk,
    input logic memWrite,
    input logic[(`WORD - 1):0] address, wdata,

    output logic[(`WORD - 1):0] readData
);
    reg[(`WORD - 1):0] RAM[0 :((1 << DMEM_POWER) - 1)] /*verilator public*/;
    
    always_ff @(posedge clk) begin
        if (memWrite) RAM[address] <= wdata;
    end

    assign readData = RAM[address];

endmodule