`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/18 16:30:02
// Design Name: 
// Module Name: shiftleft
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


module shiftleft(input [31:0] imm,
    output [31:0] offset
    );
    assign offset = {imm [30:0], 1'b0};
endmodule
