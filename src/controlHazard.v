`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/07 10:23:28
// Design Name: 
// Module Name: CONTROL
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

module branchForwarding (
    input [4:0] rs1, rs2, rd_EX, rd_MEM,
    input RegWrite_EX, MemRead_EX, RegWrite_MEM,
    output [1:0] branch_forwardA, branch_forwardB 
);

    assign branch_forwardA = (RegWrite_EX & !MemRead_EX & (rd_EX != 0) & (rs1 == rd_EX)) ? 2'b10 
                                                                           : (RegWrite_MEM & (rd_EX != 0) & (rs1 == rd_MEM)) 
                                                                           ? 2'b01 : 2'b00;
    assign branch_forwardB = (RegWrite_EX & !MemRead_EX & (rd_EX != 0) & (rs2 == rd_EX)) ? 2'b10 
                                                                           : (RegWrite_MEM & (rd_EX != 0) & (rs2 == rd_MEM)) ? 2'b01 : 2'b00;
    
endmodule

//if an ALU instruction immediately preceding a branch produces the operand for the test in the conditional branch, 
//a stall will be required.
//By extension, if a load is immediately followed by a conditional branch that depends on the load result, 
//two stall cycles will be needed
module branchhazardDetection (
    input [4:0] rs1, rs2, rd_ID, rd_EX,
    input Branch, MemRead, 
    output PCWrite, IDWrite, CtrlSrc
);
    assign PCWrite = Branch && (((rd_ID == rs1 || rd_ID == rs2) && (rd_ID != 0)) || (MemRead && (rd_EX == rs1 || rd_EX == rs2) && (rd_EX != 0))) ? 0 : 1;
    assign IDWrite = Branch && (((rd_ID == rs1 || rd_ID == rs2) && (rd_ID != 0)) || (MemRead && (rd_EX == rs1 || rd_EX == rs2) && (rd_EX != 0))) ? 0 : 1;
    assign CtrlSrc = Branch && (((rd_ID == rs1 || rd_ID == rs2) && (rd_ID != 0)) || (MemRead && (rd_EX == rs1 || rd_EX == rs2) && (rd_EX != 0))) ? 1 : 0;    
endmodule

