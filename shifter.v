module shifter (In, Cnt, Op, Out);
   
   input [15:0] In;
   input [3:0]  Cnt;
   input [1:0]  Op;
   output [15:0] Out;

   reg [15:0] shift1, shift2, shift4, shift8;
   wire [15:0] res1, res2, res3;

   /*
      OPS:
      00 - Rotate left
      01 - SHift Left Logical
      10 - Rotate RIght
      11 - Shift Right logical
   */

   always @ (*) begin
      case (Op)
         2'b00: begin      // rotate left
            assign shift1 = {In[14:0], In[15]};
            assign shift2 = {res1[13:0], res1[15:14]};
            assign shift4 = {res2[11:0], res2[15:12]};
            assign shift8 = {res3[7:0], res3[15:8]};
         end
         2'b01:   begin    // shift left logical
            assign shift1 = {In[14:0], 1'd0};          // shift by 1
            assign shift2 = {res1[13:0], 2'd0};      // shift by 2
            assign shift4 = {res2[11:0], 4'd0};    // shift by 4
            assign shift8 = {res3[7:0], 8'd0};       // shift by 8
         end
         2'b10: begin      // Rotate right
            assign shift1 = {In[0], In[15:1]};
            assign shift2 = {res1[1:0], res1[15:2]};
            assign shift4 = {res2[3:0], res2[15:4]};
            assign shift8 = {res3[7:0], res3[15:8]};
         end
         2'b11: begin      // shift right logical
            assign shift1 = {1'h0, In[15:1]};
            assign shift2 = {2'h0, res1[15:2]};
            assign shift4 = {4'h0, res2[15:4]};
            assign shift8 = {8'h0, res3[15:8]};
         end
      endcase
   end
   
   assign res1 = (Cnt[0]) ? shift1 : In;
   assign res2 = (Cnt[1]) ? shift2 : res1;
   assign res3 = (Cnt[2]) ? shift4 : res2;
   assign Out = (Cnt[3]) ? shift8 : res3;
   
endmodule

