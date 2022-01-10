module writeback (
    input [15:0] mem_out,
    input [15:0] alu_out,
    input MemToReg,
    input Jump,
    input [15:0] PC,
    output [15:0] writedata
);
    assign writedata = (Jump) ? PC : (MemToReg) ? mem_out : alu_out;

endmodule