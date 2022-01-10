/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   /**
      signal naming convention: no suffix => freshly generated signal.
      _fd => output of IF/ID register
      _dx => output of ID/EX register
      ..
      pc means pc + 2 which i incremented in fetch before outputting to proc
      just to make it easy to read
   */

   // dataflow signals/ pipelined signals
   wire err_fetch, err_decode, err_mem;
   wire [15:0] instr, instr_fd, pc, pc_fd, pc_dx, pc_xm, pc_mw;
   wire [15:0] PC_jdisp, PC_br, epc_in, epc_out;
   wire [15:0] reg1data, reg1data_dx, reg2data, reg2data_dx, reg2data_xm;
   wire [15:0] intermediate, intermediate_dx, displacement, displacement_dx;
   wire [15:0] alu_out, alu_out_xm, alu_out_mw, mem_out, mem_out_mw, writedata;
   wire [2:0] writereg, writereg_dx, writereg_xm, writereg_mw, RegisterRs, RegisterRs_dx, RegisterRt, RegisterRt_dx;
   

   // control signals
   wire [1:0] RegDest, frwrd_alu1, frwrd_alu2;
   wire [3:0] alu_op, alu_op_dx;
   wire RegWrite, RegWrite_dx, RegWrite_xm, RegWrite_mw, sext, interm_src, flush, siic, rti;
   wire MemToReg, MemToReg_dx, MemToReg_xm, MemToReg_mw, MemRead, MemRead_dx, MemRead_xm, MemWrite, MemWrite_dx, MemWrite_xm;
   wire ALU_Src, ALU_Src_dx;
   wire [2:0] branch_sel, branch_sel_dx, frwrd_branch, nextpc_sel, nextpc_sel_delayed, nextpc_sel_delayed_dx;
   wire Jump_sel, Jump_sel_dx, Jump, Jump_dx, halt, halt_dx, halt_xm, halt_mw;

   assign err = err_fetch | err_decode | err_mem;

   // fetch unit
   fetch fetch0   (.clk(clk), .rst(rst), .err(err_fetch), .PC_plus2(pc), .PC_jdisp(PC_jdisp), .PC_br(PC_br), .PC_jalu(alu_out),
                  .instr(instr), .nextpc_sel(nextpc_sel), .nextpc_sel_delayed(nextpc_sel_delayed_dx), .epc_out(epc_out));
   F_D_reg fd_reg (.clk(clk), .rst(rst), .instr_in(instr), .pc_in(pc), .instr_out(instr_fd), .pc_out(pc_fd), .flush_in(flush), .flush_out(flush_fd),
                  .flush_second_in(flush_second_dx), .flush_second_out(flush_second_fd));


   // control unit -> within decode stage of pipeline
   control ctrl0  (.instr(instr_fd), .flush_fd(flush_fd), .flush_second_fd(flush_second_fd), .branch_sel(branch_sel), .sext(sext), .Jump_sel(Jump_sel), .Jump(Jump),
                  .RegDest(RegDest), .alu_op(alu_op), .RegWrite(RegWrite), .MemToReg(MemToReg), .MemRead(MemRead), 
                  .MemWrite(MemWrite), .ALU_Src(ALU_Src), .interm_src(interm_src), .halt(halt), .siic(siic), .rti(rti));
   // decode unit  =>  (Registers, PC nxt calc)
   decode decode0 (.clk(clk), .rst(rst), .err(err_decode), .instr_fd(instr_fd), .sext(sext), .interm_src(interm_src), .displacement(displacement),
                  .intermediate(intermediate), .reg1data(reg1data), .reg2data(reg2data), .writedata(writedata), .RegDest(RegDest), .RegWrite(RegWrite_mw),
                  .RegisterRd(writereg), .writereg_in(writereg_mw), .RegisterRs(RegisterRs), .RegisterRt(RegisterRt), .PC_jdisp(PC_jdisp), .PC_br(PC_br),
                  .pc(pc_fd), .nextpc_sel(nextpc_sel), .Jump(Jump), .Jump_sel(Jump_sel), .branch_sel(branch_sel), .flush(flush), .frwrd_branch(frwrd_branch),
                  .alu_out_xm(alu_out_xm), .alu_out(alu_out), .flush_fd(flush_fd), .flush_second(flush_second), .nextpc_sel_delayed(nextpc_sel_delayed), .siic(siic), .rti(rti));
   D_X_reg dx_reg (.clk(clk), .rst(rst), .displacement_in(displacement), .displacement_out(displacement_dx), 
                  .reg1data_in(reg1data), .reg1data_out(reg1data_dx), .reg2data_in(reg2data), .reg2data_out(reg2data_dx),
                  .intermediate_in(intermediate), .intermediate_out(intermediate_dx), .Jump_in(Jump), .Jump_out(Jump_dx),
                  .Jump_sel_in(Jump_sel), .Jump_sel_out(Jump_sel_dx), .branch_sel_in(branch_sel), .branch_sel_out(branch_sel_dx),
                  .ALU_Src_in(ALU_Src), .ALU_Src_out(ALU_Src_dx), .alu_op_in(alu_op), .alu_op_out(alu_op_dx), .MemRead_in(MemRead), .MemRead_out(MemRead_dx), 
                  .MemWrite_in(MemWrite), .MemWrite_out(MemWrite_dx), .MemToReg_in(MemToReg), .MemToReg_out(MemToReg_dx), .RegWrite_in(RegWrite), 
                  .RegWrite_out(RegWrite_dx), .writereg_in(writereg), .writereg_out(writereg_dx), .halt_in(halt), .halt_out(halt_dx),
                  .RegisterRs_in(RegisterRs), .RegisterRs_out(RegisterRs_dx), .RegisterRt_in(RegisterRt), .RegisterRt_out(RegisterRt_dx),
                  .pc_in(pc_fd), .pc_out(pc_dx), .flush_second_in(flush_second), .flush_second_out(flush_second_dx), .nextpc_sel_delayed_in(nextpc_sel_delayed),
                  .nextpc_sel_delayed_out(nextpc_sel_delayed_dx));

   // hazard detection unit
   hazard hazard0(.clk(clk), .rst(rst), .RegisterRs(RegisterRs), .RegisterRs_dx(RegisterRs_dx), .RegisterRt_dx(RegisterRt_dx), .RegisterRd_xm(writereg_xm), .RegisterRd_mw(writereg_mw), .RegWrite_xm(RegWrite_xm), .RegWrite_mw(RegWrite_mw),
                  .frwrd_alu1(frwrd_alu1), .frwrd_alu2(frwrd_alu2), .writedata(writedata), .nextpc_sel(nextpc_sel),
                  .frwrd_branch(frwrd_branch), .ALU_Src_dx(ALU_Src_dx), .RegisterRd_dx(writereg_dx), .RegWrite_dx(RegWrite_dx),
                  .MemRead_dx(MemRead_dx));

   // execute unit
   execute execute0(.reg1data(reg1data_dx), .reg2data(reg2data_dx), .alu_out(alu_out), .displacement(displacement_dx),
                     .alu_op(alu_op_dx), .intermediate(intermediate_dx), .ALU_Src(ALU_Src_dx), .writedata(writedata),
                     .frwrd_alu1(frwrd_alu1), .frwrd_alu2(frwrd_alu2), .alu_out_xm(alu_out_xm),
                     .writedata_prev(writedata_prev));
   X_M_reg xm_reg(.clk(clk), .rst(rst), .alu_out_in(alu_out), .alu_out_out(alu_out_xm), .reg2data_in(reg2data), .reg2data_out(reg2data_xm),
                  .MemWrite_in(MemWrite_dx), .MemWrite_out(MemWrite_xm), .MemRead_in(MemRead_dx), .MemRead_out(MemRead_xm), .pc_in(pc_dx), .pc_out(pc_xm),
                  .MemToReg_in(MemToReg_dx), .MemToReg_out(MemToReg_xm), .RegWrite_in(RegWrite_dx), .RegWrite_out(RegWrite_xm), .Jump_in(Jump_dx), .Jump_out(Jump_xm),
                  .writereg_in(writereg_dx), .writereg_out(writereg_xm), .halt_in(halt_dx), .halt_out(halt_xm));
   

   // memory unit
   memory memory0(.clk(clk), .rst(rst), .addr(alu_out_xm), .MemWrite(MemWrite_xm), .MemRead(MemRead_xm), .writeData(reg2data_xm), .mem_out(mem_out));
   M_W_reg mw_reg(.clk(clk), .rst(rst), .Jump_in(Jump_xm), .Jump_out(Jump_mw), .pc_in(pc_xm), .pc_out(pc_mw), .alu_out_in(alu_out_xm), .alu_out_out(alu_out_mw),
                  .mem_out_in(mem_out), .mem_out_out(mem_out_mw), .MemToReg_in(MemToReg_xm), .MemToReg_out(MemToReg_mw), .RegWrite_in(RegWrite_xm), .RegWrite_out(RegWrite_mw),
                  .writereg_in(writereg_xm), .writereg_out(writereg_mw), .halt_in(halt_xm), .halt_out(halt_mw));


   //writeback unit
   writeback writeback0(.mem_out(mem_out_mw), .alu_out(alu_out_mw), .MemToReg(MemToReg_mw), .Jump(Jump_mw), .PC(pc_mw), .writedata(writedata));


   assign epc_in = (siic) ? pc : epc_out;
   // EPC register
   dff epc[15:0](.q(epc_out), .d(epc_in), .clk(clk), .rst(rst));

endmodule // proc
// DUMMY LINE FOR REV CONTROL :0: