module F_D_reg (
    input clk,
    input rst,
    
    input [15:0] instr_in,
    input [15:0] pc_in,
    input flush_in,
    input flush_second_in,

    output [15:0] instr_out,
    output [15:0] pc_out,
    output flush_second_out,
    output flush_out
);

    //wire [15:0] instr_q;    // intermediate instr reg output

    //dff instr_reg[15:0] (.q(instr_q), .d(instr_d), .clk(clk), .rst(rst));
    dff_instr instr_reg (.q(instr_out), .d(instr_in), .clk(clk), .rst(rst));
    dff pc_reg[15:0] (.q(pc_out), .d(pc_in), .clk(clk), .rst(rst));
    dff flush_reg (.q(flush_out), .d(flush_in), .clk(clk), .rst(rst));
    dff flush_second_reg (.q(flush_second_out), .d(flush_second_in), .clk(clk), .rst(rst));
    
endmodule