`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/17 11:01:12
// Design Name: 
// Module Name: alu
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


module alu 
    #(parameter size = 32)
    (input [size-1:0] a,
    input [size-1:0] b,
    input [3:0] ALUctrl,
    output reg [size-1:0] result,
    output zero
    );    
    assign zero = (result == 0);
    always @(*) begin
        case (ALUctrl)
            4'b0000: result = a & b;
            4'b0001: result = a | b;
            4'b0010: result = a + b;
            4'b0110: result = a - b;
            4'b0111: result = a < b ? 1 : 0;
            4'b1100: result = ~(a | b);
            default: result = 0;
        endcase
    end
endmodule
