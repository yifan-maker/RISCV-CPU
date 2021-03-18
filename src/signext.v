`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/18 11:58:06
// Design Name: 
// Module Name: signext
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


module signext(input [31:0] instr,
    output reg [31:0] imm
    );
    always @(*) begin
        if (instr [6:5] == 2'b00) begin
            imm = {{20{instr[31]}}, instr [31:20]};    //lw 
        end
        else if (instr [6:5] == 2'b01) begin
            imm = {{20{instr[31]}}, instr [31:25], instr [11:7]};    //sw
        end
        else if (instr [6:2] == 5'b1_1000) begin
            imm = {{20{instr[31]}}, instr [31], instr [7], instr [30:25], instr [11:8]};    //beq
        end
        else if (instr [6:2] == 5'b1_1011 ) begin
            imm = {{12{instr[31]}}, instr [31], instr [19:12], instr [20], instr [30:21]};   //jal, U type
        end
        else
            imm = 32'h0000_0000;    
    end
endmodule
