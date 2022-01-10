module execute(
    input [15:0] reg1data,
    input [15:0] reg2data,
    output reg [15:0] alu_out,
    input [3:0] alu_op,
    input [15:0] intermediate,
    input [15:0] displacement,
    input ALU_Src,
    input [1:0] frwrd_alu1,
    input [1:0] frwrd_alu2,
    input [15:0] writedata,
    input [15:0] writedata_prev,
    input [15:0] alu_out_xm
);
    wire [15:0] shifter_out, btr_out;
    wire [1:0] shifter_op;
    wire [3:0] shifter_cnt;
    wire [16:0] difference, sco_sum; // 17 bit values to store carry out bit
    wire [16:0] data1_sext, data2_sext;

    reg [15:0] data1, data2;

    // forwarding muxes
    always @(*) begin
        case(frwrd_alu1)
            2'd1: data1 = writedata;
            2'd2: data1 = alu_out_xm;
            2'd3: data1 = writedata_prev;    // from hazard unit
            default: data1 = reg1data;  // no forwarding alu input
        endcase
        case (frwrd_alu2)
            2'd1: data2 = writedata;
            2'd2: data2 = alu_out_xm;
            2'd3: data2 = writedata_prev;
            default: data2 = (ALU_Src) ? intermediate : reg2data; // no forwarding -> independent register or intermediate
        endcase
    end

    assign data1_sext = {data1[15], data1};
    assign data2_sext = {data2[15], data2};

    assign difference = data1_sext - data2_sext;
    assign sco_sum = data1 + data2;             // replace with adder / use same adder (maybe adder result should be 17 bits and alu only uses 16 bits)

    // ALU
    always @(*) begin
        case (alu_op)                                               // replace with adder
            4'h0: alu_out = data1 + data2;               // add 
            4'h1: alu_out = data2 - data1;               // sub
            4'h2: alu_out = data1 ^ data2;               // xor
            4'h3: alu_out = data1 & ~data2;              // ANDN
            4'h4: alu_out = ~|difference;                // SEQ
            4'h5: alu_out = difference[16];              // SLT
            4'h6: alu_out = ~|difference | difference[16];  // SLE
            4'h7: alu_out = sco_sum[16];                    // SCO
            4'h8: alu_out = shifter_out;                // ROL
            4'h9: alu_out = shifter_out;                // SLL
            4'ha: alu_out = shifter_out;                // ROR
            4'hb: alu_out = shifter_out;                // SRL
            4'hc: alu_out = data1 & data2;              // AND
            4'hd: alu_out = intermediate;               // LBI
            4'he: alu_out = {data1[7:0], intermediate[7:0]}; // SLBI
            4'hf: alu_out = btr_out;                    // BTR
            default: alu_out = 0;
        endcase
    end

    // instance shifter
    assign shifter_op = alu_op[1:0];
    assign shifter_cnt = data2[3:0];

    shifter shifter0(.In(data1), .Cnt(shifter_cnt), .Op(shifter_op), .Out(shifter_out));

    // btr
    assign btr_out = {data1[0], data1[1], data1[2], data1[3], data1[4],
                     data1[5], data1[6], data1[7], data1[8], data1[9],
                     data1[10], data1[11], data1[12], data1[13], data1[14], data1[15]};


endmodule