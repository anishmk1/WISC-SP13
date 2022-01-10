module dff_instr(clk, rst, q, d);

    input clk;
    input rst;
    input [15:0] d;
    output reg [15:0] q;

    always @(posedge clk) begin
        if (rst)
            q <= 16'h0800;
        else
            q <= d;
    end

endmodule