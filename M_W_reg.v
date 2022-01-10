module M_W_reg(
    input clk,
    input rst,

    input Jump_in,
    input MemToReg_in,
    input [15:0] pc_in,
    input [15:0] alu_out_in,
    input [15:0] mem_out_in,
    input RegWrite_in,
    input [2:0] writereg_in,
    input halt_in,

    output Jump_out,
    output MemToReg_out,
    output [15:0] pc_out,
    output [15:0] alu_out_out,
    output [15:0] mem_out_out,
    output RegWrite_out,
    output [2:0] writereg_out,
    output halt_out
);

    dff Jump_reg (.q(Jump_out), .d(Jump_in), .clk(clk), .rst(rst));
    dff MemToReg_reg (.q(MemToReg_out), .d(MemToReg_in), .clk(clk), .rst(rst));
    dff pc_reg[15:0] (.q(pc_out), .d(pc_in), .clk(clk), .rst(rst));
    dff alu_out_reg[15:0] (.q(alu_out_out), .d(alu_out_in), .clk(clk), .rst(rst));
    dff mem_out_reg[15:0] (.q(mem_out_out), .d(mem_out_in), .clk(clk), .rst(rst));
    dff RegWrite_reg (.q(RegWrite_out), .d(RegWrite_in), .clk(clk), .rst(rst));
    dff writereg_reg[2:0] (.q(writereg_out), .d(writereg_in), .clk(clk), .rst(rst));
    dff halt_reg (.q(halt_out), .d(halt_in), .clk(clk), .rst(rst));

endmodule