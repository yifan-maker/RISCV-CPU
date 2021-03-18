`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/18 17:11:02
// Design Name: 
// Module Name: regfile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//note that x0 is zero constant and x1 is reserved for return address. 
//To implement jal which the return address is needed to be writen into x1 register, two write ports are implemented.
//Also, we assume that other instrutions will not write data into x1 so that two write ports writing the same register will not happen.
module regfile (input clk,
    input we,
    input [4:0] read1, read2, write1, write2,
    input [31:0] write_data1, write_data2,
    output [31:0] data_out1, data_out2
    );
    reg [31:0] rf [31:0];
    assign data_out1 = read1 == 0 ? 0 : rf [read1];
    assign data_out2 = read2 == 0 ? 0 : rf [read2];
    always @(negedge clk) begin
        if (we) begin
            if (write1 != 1) begin
                rf [write1] <= write_data1;
            end
            if (write2 == 1) begin
                rf [write2] <= write_data2;
            end
        end
        
    end
endmodule
