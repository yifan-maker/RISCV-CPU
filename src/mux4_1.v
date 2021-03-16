`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/05 10:58:18
// Design Name: 
// Module Name: mux4_1
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

//in fact, this is a mux3_1
module mux4_1(
    input [31:0] a, b, c,
    input [1:0] sel,
    output [31:0] out
    );
    
    assign out = (sel == 2'b10) ? a : (sel == 2'b01) ? b : c;

endmodule
