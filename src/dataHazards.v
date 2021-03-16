`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/05 10:23:28
// Design Name: 
// Module Name: dataHazards
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

//output control signals to select the source of ALU
//Also, COD book do not consider the case load after store which access the same address in data mem, so the additional logic is added to resolve it.
module forwarding_unit (
    input [4:0] rs1, rs2, rd_EX, rd_MEM,
    input RegWrite_EX, RegWrite_MEM, 
    output [1:0] forwardA, forwardB,
    output forward_dmem
);

    assign forwardA = (RegWrite_EX & (rd_EX != 0) & (rs1 == rd_EX)) ? 2'b10 : (RegWrite_MEM & (rd_EX != 0) & (rs1 == rd_MEM)) ? 2'b01 : 2'b00;
    assign forwardB = (RegWrite_EX & (rd_EX != 0) & (rs2 == rd_EX)) ? 2'b10 : (RegWrite_MEM & (rd_EX != 0) & (rs2 == rd_MEM)) ? 2'b01 : 2'b00;
    
endmodule

module hazardDetection (
    input [4:0] rs1, rs2, rd,
    input MemRead,
    output PCWrite, IDWrite, CtrlSrc
);
    assign PCWrite = (MemRead && (rd == rs1 || rd == rs2)) ? 0 : 1;
    assign IDWrite = (MemRead && (rd == rs1 || rd == rs2)) ? 0 : 1;
    assign CtrlSrc = (MemRead && (rd == rs1 || rd == rs2)) ? 1 : 0;    
endmodule


