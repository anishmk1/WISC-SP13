module decode(
    input clk,
    input rst,
    output err,
    input [15:0] instr_fd,
    output [15:0] reg1data,
    output [15:0] reg2data,
    input [15:0] writedata,
    output [2:0] RegisterRd,
    output [2:0] RegisterRs,
    output [2:0] RegisterRt,
    input [2:0] writereg_in,
    input [1:0] RegDest,
    input sext,
    input flush_fd,
    input siic,
    input rti,
    output reg flush,
    input [15:0] pc,
    output reg [2:0] nextpc_sel,
    output reg [2:0] nextpc_sel_delayed,
    input [2:0] frwrd_branch,
    output [15:0] PC_br,
    output [15:0] PC_jdisp,
    output reg flush_second,
    input [15:0] alu_out,
    input [15:0] alu_out_xm,
    input [2:0] branch_sel,
    input Jump_sel,
    input Jump,
    input interm_src,
    output reg [15:0] intermediate,
    output [15:0] displacement,
    input RegWrite
);

    wire [15:0] instr;

    assign instr = instr_fd;

    // instruction decode
    assign RegisterRs = instr[10:8];
    assign RegisterRt = instr[7:5];
    assign RegisterRd = (RegDest == 2'd0) ? instr[10:8] : 
                        (RegDest == 2'd1) ? instr[7:5] : 
                        (RegDest == 2'd2) ? instr[4:2] :
                        3'd7;       // write to register 7 if JAL instr

    // compute intermediate
    always @(*) begin
		if (interm_src)		// intermediate bits from instr[7:0] or instr[4:0]?
			if (sext)		// sign extend or zero extend?
				intermediate = {{8{instr[7]}}, instr[7:0]};
			else		
				intermediate = {8'h00, instr[7:0]};
		else
			if (sext)
				intermediate = {{11{instr[4]}}, instr[4:0]};
			else
				intermediate = {11'h0, instr[4:0]};
	end

    // sign extend displacement
    assign displacement = {{5{instr[10]}},instr[10:0]};
    // compute PC_br & PC_jdisp                                     // replace with adder
    assign PC_br = pc + intermediate;
    assign PC_jdisp = pc + displacement;

    reg [15:0] branch_data;
    reg branch_mux;

    always @(*) begin
        // forwarded branch data for equality testing below
        case (frwrd_branch)
            3'd1: branch_data = writedata;
            3'd2: branch_data = alu_out_xm;
            3'd4: branch_data = alu_out;
            default:  branch_data = reg1data;
        endcase
        // intermediate branch logic
        case (branch_sel)
            3'b100: branch_mux = ~|branch_data;      // BEQZ    4
            3'b101: branch_mux = |branch_data;       // BNEZ    5
            3'b110: branch_mux = branch_data[15];   // BLTZ     6
            3'b111: branch_mux = ~branch_data[15];   // BGEZ    7
            default: branch_mux = 0;    // not a Branch
        endcase
    end 

    // nextpc_sel mux assignment using intermediate branch logic
    always @(*) begin
        flush = 0;
        flush_second = 0;
        //stall = 0;
        if (flush_fd) begin
            nextpc_sel = 0;
        end
        else if (siic) begin
            nextpc_sel = 4;
        end
        else if (rti) begin
            nextpc_sel = 5;
        end
        else if (branch_mux) begin
            nextpc_sel = 2;        // branch
            flush = 1;              // flush instruction currently being fetched
        end 
        else if (Jump) begin
            flush = 1;
            if (Jump_sel) begin
                // nextpc_sel = 3;    // jump with alu result
                nextpc_sel_delayed = 3;
                flush_second = 1;   // alu result ready one cycle later
            end
            else
                nextpc_sel = 1;    // jump with immediate
        end 
        else begin
            nextpc_sel = 0;        // no branch/jump
            nextpc_sel_delayed = 0;
        end
    end

    // register file
    rf regFile0(.clk(clk), .rst(rst), .read1regsel(RegisterRs), 
        .read2regsel(RegisterRt), .writeregsel(writereg_in), .writedata(writedata), 
        .write(RegWrite), .read1data(reg1data), .read2data(reg2data), .err(err));


endmodule