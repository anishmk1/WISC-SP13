module fetch (clk, rst, err, instr, PC_plus2, nextpc_sel, nextpc_sel_delayed, PC_jdisp, PC_br, PC_jalu, epc_out);

	input clk;
	input rst;
	input [2:0] nextpc_sel;
	input [2:0] nextpc_sel_delayed;
	input [15:0] PC_jdisp;
	input [15:0] PC_br;
	input [15:0] PC_jalu;
	input [15:0] epc_out;
	output [15:0] PC_plus2;
	output err;
	output [15:0] instr;

	reg [15:0] PC_nxt;

	wire [15:0] PC, PC_stall;
	wire [2:0] nextpc_sel_true;

	assign err = 1'b0;
	assign nextpc_sel_true = (nextpc_sel_delayed == 0) ? nextpc_sel : nextpc_sel_delayed;

	// PC register
	dff iPC_reg[15:0](.q(PC), .d(PC_nxt), .clk(clk), .rst(rst));

	// UPDATE PC
    always @(*) begin
        case (nextpc_sel_true)
            3'd1: PC_nxt = PC_jdisp;	// PC + 2 + displacement;
            3'd2: PC_nxt = PC_br; 		// PC + 2 + intermediate;
            3'd3: PC_nxt = PC_jalu;		// direct alu output
			3'd4: PC_nxt = 16'h0002;		// siic
			3'd5: PC_nxt = epc_out;
            default: PC_nxt = PC_stall;
        endcase
    end

	assign PC_plus2 = PC + 2;	// swap with adder
	
	// assign PC_stall = (stall) ? PC : PC_plus2;
	assign PC_stall = PC_plus2;

	// Fetch instruction
	memory2c instr_mem(.data_out(instr), .data_in(16'h0000), .addr(PC), .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));

endmodule