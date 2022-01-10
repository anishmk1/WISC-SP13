/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module rf (
           // Outputs
           read1data, read2data, err,
           // Inputs
           clk, rst, read1regsel, read2regsel, writeregsel, writedata, write
           );
    input clk, rst;
    input [2:0] read1regsel;
    input [2:0] read2regsel;
    input [2:0] writeregsel;
    input [15:0] writedata;
    input        write;

    output [15:0] read1data;
    output [15:0] read2data;
    output        err;

    wire [15:0] reg_data [7:0];         // 16 bit data held in registers 0 to 7
    wire [15:0] reg_data_in [7:0];      // input to dff, if write enabled then becomes writedata, else holds

    // 8 16-bit wide registers
    dff iregisters1[15:0] (.q(reg_data[0]), .d(reg_data_in[0]), .clk(clk), .rst(rst));
    dff iregisters2[15:0] (.q(reg_data[1]), .d(reg_data_in[1]), .clk(clk), .rst(rst));
    dff iregisters3[15:0] (.q(reg_data[2]), .d(reg_data_in[2]), .clk(clk), .rst(rst));
    dff iregisters4[15:0] (.q(reg_data[3]), .d(reg_data_in[3]), .clk(clk), .rst(rst));
    dff iregisters5[15:0] (.q(reg_data[4]), .d(reg_data_in[4]), .clk(clk), .rst(rst));
    dff iregisters6[15:0] (.q(reg_data[5]), .d(reg_data_in[5]), .clk(clk), .rst(rst));
    dff iregisters7[15:0] (.q(reg_data[6]), .d(reg_data_in[6]), .clk(clk), .rst(rst));
    dff iregisters8[15:0] (.q(reg_data[7]), .d(reg_data_in[7]), .clk(clk), .rst(rst));

    // Write to specified register when write enabled
    assign reg_data_in[0] = (write && writeregsel==0) ? writedata : reg_data[0];
    assign reg_data_in[1] = (write && writeregsel==1) ? writedata : reg_data[1];
    assign reg_data_in[2] = (write && writeregsel==2) ? writedata : reg_data[2];
    assign reg_data_in[3] = (write && writeregsel==3) ? writedata : reg_data[3];
    assign reg_data_in[4] = (write && writeregsel==4) ? writedata : reg_data[4];
    assign reg_data_in[5] = (write && writeregsel==5) ? writedata : reg_data[5];
    assign reg_data_in[6] = (write && writeregsel==6) ? writedata : reg_data[6];
    assign reg_data_in[7] = (write && writeregsel==7) ? writedata : reg_data[7];

    // read from register file
    assign read1data = (write & (writeregsel == read1regsel)) ? writedata: reg_data[read1regsel];
    assign read2data = (write & (writeregsel == read2regsel)) ? writedata: reg_data[read2regsel];

    assign err = 1'b0;

endmodule
// DUMMY LINE FOR REV CONTROL :1:
