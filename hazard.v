module hazard(
    input clk,
    input rst,
    input [2:0] RegisterRs,     // straight from decode. for frwrd branch
    input [2:0] RegisterRs_dx,  
    input [2:0] RegisterRt_dx,
    input [2:0] RegisterRd_xm,
    input [2:0] RegisterRd_dx,
    input [2:0] RegisterRd_mw,
    input RegWrite_xm,
    input RegWrite_dx,
    input MemRead_dx,
    input ALU_Src_dx,
    input [2:0] nextpc_sel,
    input RegWrite_mw,
    input [15:0] writedata,    // currently being written to register file
    output reg stall,
    output reg [1:0] frwrd_alu1,
    output reg [1:0] frwrd_alu2,
    output reg [2:0] frwrd_branch
);

    // DATA HAZARD/ FORWARDING UNIT
    always @(*) begin
        frwrd_alu1 = 0; // default alu inputs to come from dx reg (no forwarding)
        frwrd_alu2 = 0;
        frwrd_branch = 0;
        //flush = 0;
        
        // forwarding for alu1 input in EXECUTE
        if (RegWrite_xm & (RegisterRd_xm != 0) & (RegisterRd_xm == RegisterRs_dx)) begin
            frwrd_alu1 = 2;     // check for Rs xm dependency
        end
        // if xm dependency found no need to check for mw and mw_prev dependencies. use most recent value
        else if (RegWrite_mw & (RegisterRd_mw != 0) & (RegisterRd_mw == RegisterRs_dx)) begin
            frwrd_alu1 = 1;     // check for Rs mw dependency      
        end

        // forwarding for ALU2 input in EXECUTE
        if (ALU_Src_dx) begin      // no forwarding for alu2 required if i type instruction
            frwrd_alu2 = 0;
        end
        else if (RegWrite_xm & (RegisterRd_xm != 0) & (RegisterRd_xm == RegisterRt_dx)) begin
            frwrd_alu2 = 2;     // check for Rt xm dependency
        end
        else if (RegWrite_mw & (RegisterRd_mw != 0) & (RegisterRd_mw == RegisterRt_dx)) begin
            frwrd_alu2 = 1;     // check for Rt mw dependency      
        end


        // forwarding for branch decision logic in DECODE stage
        if (RegWrite_dx & (RegisterRd_dx != 0) & (RegisterRd_dx == RegisterRs)) begin
            if (MemRead_dx) begin
                // previous instr was a load. need to stall for two cycles
            end
            else begin  // flush currently fetching instr
                frwrd_branch = 4;   // frwrd branch data from alu_out to decode stage
            end
            
        end
        if (RegWrite_xm & (RegisterRd_xm != 0) & (RegisterRd_xm == RegisterRs)) begin
            frwrd_branch = 2;     // check for Rs xm dependency
        end
        else if (RegWrite_mw & (RegisterRd_mw != 0) & (RegisterRd_mw == RegisterRs)) begin
            frwrd_branch = 1;     // check for Rs mw dependency      
        end

    end

    // // Load-use data Hazard detection unit => Reg read immediately after a Load. Memory read not completed in time for next instr execute stage. 
    // // Need to stall pipeline
    // always @(*) begin
    //     if (MemRead_dx) begin
    //     // is the load going to write to a reg that we'll read from right after? 
    //         if (RegisterRt_dx == RegisterRs_fd | RegisterRt_dx == RegisterRt_fd) begin
    //             // stall the pipeline
    //             // 1) tell the control unit to zero all the relevant control signals that are going into the dx reg.
    //             // 2) hold pc in place so that the instructions currently in F and D stage stay there
    //         end   
    //     end
    // end
    
endmodule