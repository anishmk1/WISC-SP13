module control(
    input [15:0] instr,
    input flush_fd,
    input flush_second_fd,
    output reg [1:0] RegDest,
    output reg [3:0] alu_op,
    output reg MemToReg,
    output reg MemRead,
    output reg siic,
    output reg rti,
    output reg MemWrite,
    output reg RegWrite,
    output reg ALU_Src,
    output reg sext,
    output reg interm_src,
    output reg [2:0] branch_sel,
    output reg Jump_sel,
    output reg Jump,
    output reg halt
);

    wire [4:0] opcode;

    assign opcode = instr[15:11];

    always @(*) begin
        // default outputs
        MemToReg = 0;
        MemRead = 0;
        MemWrite = 0;
        RegWrite = 0;
        ALU_Src = 0;
        interm_src = 0;
        RegDest = 2;   
        sext = 1;                // sign extend by default
        branch_sel = 3'b000;     // not a branch instr
        Jump_sel = 0;
        Jump = 0;
        alu_op = 0;
        halt = 0;
        siic = 0;
        rti = 0;

        case (opcode[4:2]) 
            3'b110: begin                       // R type
                RegDest = 2;
                alu_op = {1'b0,instr[1:0]};
                
                case (opcode[1:0])
                    2'b00: begin                // LBI instr
                        RegDest = 0;
                        RegWrite = 1;
                        sext = 1;
                        interm_src = 1;  // intermediate comes from instr[7:0]
                        ALU_Src = 1;
                        alu_op = 4'hd;
                    end
                    2'b01: begin                // BTR instr
                        ALU_Src = 1;
                        RegWrite = 1;
                        alu_op = 4'hf;  // btr op
                    end
                    2'b10: begin                // r type shift
                        ALU_Src = 0;
                        alu_op = {2'b10, instr[1:0]};
                        RegDest = 2;
                        RegWrite = 1;
                    end
                    2'b11: begin                // r type arithmetic
                        ALU_Src = 0;
                        RegWrite = 1;
                    end
                endcase
            end
            3'b010: begin                       // I type arithmetic
                RegWrite = 1;
                ALU_Src = 1;
                RegDest = 1;
                alu_op = {1'b0,opcode[1:0]};
                sext = ~opcode[1];      // zero extend for XORI and ANDNI instr
            end
            3'b101: begin                       // I type shift
                ALU_Src = 1;
                RegDest = 1;
                RegWrite = 1;
                alu_op = {2'b10,opcode[1:0]};
            end
            3'b100: begin                       // MEMORY / slbi intructions
                case (opcode[1:0])
                    2'b00: begin                // STORE
                        RegWrite = 0;
                        MemWrite = 1;
                        alu_op = 0;     // add
                        ALU_Src = 1;    // select interm
                        interm_src = 0; // 5 bit interm
                        sext = 1;
                    end
                    2'b01: begin                // LOAD
                        RegWrite = 1;
                        RegDest = 1;
                        MemRead = 1;
                        MemToReg = 1;
                        alu_op = 0;     // add
                        ALU_Src = 1;    // interm
                        interm_src = 0; // 5 bit interm
                        sext = 1;
                    end
                    2'b10: begin                // SLBI
                        RegDest = 0;
                        RegWrite = 1;
                        ALU_Src = 1;
                        interm_src = 1;  // 8 bit intermediate
                        sext = 0;       // zero extend immediate
                        alu_op = 4'he;
                    end
                    2'b11: begin                // STU
                        RegDest = 0;    // write to rs bits
                        RegWrite = 1;
                        MemWrite = 1;
                        MemToReg = 0;   // write effective addr to Rs
                        alu_op = 0;     // add
                        ALU_Src = 1;    // select interm
                        interm_src = 0; // 5 bit interm
                        sext = 1;
                    end
                    default: begin
                        
                    end
                endcase
                
            end
            3'b011: begin        // BRANCHES
                interm_src = 1;          // intermediate comes from instr[7:0]
                sext = 1;
                branch_sel = opcode[2:0];
            end
            3'b001: begin               // Jump instruction
                Jump_sel = opcode[0];   // 0 => addr displacement from instruction | 1 => addr displacement from alu result
                RegDest = (opcode[1]) ? 3 : 2;  // select R7 if JAL/ JALR
                RegWrite = opcode[1]; // 1 if JAL/JALR
                interm_src = 1;  // intermediate not used for displacement instrs anyway
                alu_op = 0;
                ALU_Src = 1;
                sext = 1;
                Jump = 1;
            end
            3'b111: begin       // SET instruction
                alu_op = opcode[2:0];
                RegDest = 2;
                ALU_Src = 0;
                RegWrite = 1;
            end
            3'b000: begin       // other instrs
                case (opcode[1:0])
                    2'b00: begin
                        halt = 1;
                    end
                    2'b01: begin
                        // NOP
                    end
                    2'b10: begin
                        // siic
                        siic = 1;
                    end
                    2'b11: begin
                        // RTI
                        rti = 1;
                    end
                    default: begin
                        // do nothing
                    end
                endcase
            end
            default: begin
                
            end
        endcase

        if (flush_fd | flush_second_fd) begin
            // zero all relevant control signals
            RegWrite = 0;   // also disables hazard detection
            MemWrite = 0;
            MemRead = 0;
            halt = 0;
        end

    end
endmodule