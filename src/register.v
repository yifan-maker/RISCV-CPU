`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/25 11:16:53
// Design Name: 
// Module Name: register
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


module register #(parameter size = 32) (
    input load,
    input clk,
    input rst, clear,
    input [size-1:0] in,
    output reg [size-1:0] out
    );
    always @(posedge clk) begin
        if (rst)
            out <= 0;
        else if (clear)
            out <= 0;
        else if (load)
            out <= in;
        
    end
endmodule