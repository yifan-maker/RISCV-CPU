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


module regfile (input clk,
    input we,
    input [4:0] read1, read2, write,
    input [31:0] write_data,
    output [31:0] data_out1, data_out2
    );
    reg [31:0] rf [31:0];
    assign data_out1 = read1 == 0 ? 0 : rf [read1];
    assign data_out2 = read2 == 0 ? 0 : rf [read2];
    always @(negedge clk) begin
        if (we) begin
            rf [write] <= write_data;
        end
        
    end
endmodule
