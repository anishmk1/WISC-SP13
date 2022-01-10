module D_X_reg (
    input clk,
    input rst,

    input [15:0] displacement_in,
    input [15:0] reg1data_in,
    input [15:0] reg2data_in,
    input [15:0] intermediate_in,
    input [15:0] pc_in,
    input Jump_in,
    input Jump_sel_in,
    input [2:0] branch_sel_in,
    input ALU_Src_in,
    input [3:0] alu_op_in,
    input MemRead_in,
    input MemWrite_in,
    input MemToReg_in,
    input RegWrite_in,
    input flush_second_in,
    input [2:0] writereg_in,
    input halt_in,
    input [2:0] nextpc_sel_delayed_in,
    input [2:0] RegisterRs_in,
    input [2:0] RegisterRt_in,

    output [15:0] reg1data_out,
    output [15:0] reg2data_out,
    output [15:0] displacement_out,
    output [15:0] intermediate_out,
    output [15:0] pc_out,
    output Jump_out,
    output Jump_sel_out,
    output [2:0] branch_sel_out,
    output ALU_Src_out,
    output [3:0] alu_op_out,
    output MemRead_out,
    output MemWrite_out,
    output MemToReg_out,
    output RegWrite_out,
    output flush_second_out,
    output [2:0] writereg_out,
    output halt_out,
    output [2:0] nextpc_sel_delayed_out,
    output [2:0] RegisterRs_out,
    output [2:0] RegisterRt_out
);

    dff disp_reg[15:0] (.q(displacement_out), .d(displacement_in), .clk(clk), .rst(rst));
    dff reg1data_reg[15:0] (.q(reg1data_out), .d(reg1data_in), .clk(clk), .rst(rst));
    dff reg2data_reg[15:0] (.q(reg2data_out), .d(reg2data_in), .clk(clk), .rst(rst));
    dff interm_reg[15:0] (.q(intermediate_out), .d(intermediate_in), .clk(clk), .rst(rst));
    dff pc_reg[15:0] (.q(pc_out), .d(pc_in), .clk(clk), .rst(rst));
    dff Jump_reg (.q(Jump_out), .d(Jump_in), .clk(clk), .rst(rst));
    dff flush_reg (.q(flush_second_out), .d(flush_second_in), .clk(clk), .rst(rst));
    dff Jump_sel_reg (.q(Jump_sel_out), .d(Jump_sel_in), .clk(clk), .rst(rst));
    dff branch_sel_reg[2:0] (.q(branch_sel_out), .d(branch_sel_in), .clk(clk), .rst(rst));
    dff alu_op_reg[3:0] (.q(alu_op_out), .d(alu_op_in), .clk(clk), .rst(rst));
    dff alu_src_reg (.q(ALU_Src_out), .d(ALU_Src_in), .clk(clk), .rst(rst));
    dff MemRead_reg (.q(MemRead_out), .d(MemRead_in), .clk(clk), .rst(rst));
    dff MemWrite_reg (.q(MemWrite_out), .d(MemWrite_in), .clk(clk), .rst(rst));
    dff MemToReg_reg (.q(MemToReg_out), .d(MemToReg_in), .clk(clk), .rst(rst));
    dff RegWrite_reg (.q(RegWrite_out), .d(RegWrite_in), .clk(clk), .rst(rst));
    dff nextpc_sel_delay_reg[2:0] (.q(nextpc_sel_delayed_out), .d(nextpc_sel_delayed_in), .clk(clk), .rst(rst));
    dff writereg_reg[2:0] (.q(writereg_out), .d(writereg_in), .clk(clk), .rst(rst));
    dff halt_reg (.q(halt_out), .d(halt_in), .clk(clk), .rst(rst));
    dff RegisterRs_reg[2:0] (.q(RegisterRs_out), .d(RegisterRs_in), .clk(clk), .rst(rst));
    dff RegisterRt_reg[2:0] (.q(RegisterRt_out), .d(RegisterRt_in), .clk(clk), .rst(rst));

endmodule