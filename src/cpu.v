`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/20 21:40:41
// Design Name: 
// Module Name: cpu
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


module cpu(
    input clk,rst,
    input [31:0] instr, dread_mem,
    output [31:0] result, instr_addr, rs2,
    output instrmem_en,datamem_en, datamem_we
    );

    assign instrmem_en = 1'b1;  //always enable instruction ram

    wire RegWrite, ALUSrc, MemtoReg, Branch, Jump, mem_en, mem_we;
    wire [3:0] aluctrl;
    wire [31:0] IR;

    datapath datapath(
    .clk(clk),
    .rst(rst),
    .RegWrite(RegWrite), 
    .ALUSrc(ALUSrc), 
    .MemtoReg(MemtoReg), 
    .Branch(Branch),
    .Jump(Jump),
    .MemRead(mem_en), 
    .MemWrite(mem_we),
    .aluctrl(aluctrl),
    .instr(instr), 
    .dread_mem(dread_mem),
    .result_EX(result), 
    .instr_addr(instr_addr), 
    .rs2_EX(rs2),
    .IR_IF(IR),
    .datamem_en(datamem_en),
    .datamem_we(datamem_we)
    );

    controller controller(
    .instr(IR),
    .aluctrl(aluctrl),
    .RegWrite(RegWrite), 
    .MemRead(mem_en), 
    .MemWrite(mem_we),    // write enable in data ram
    .ALUSrc(ALUSrc), 
    .MemtoReg(MemtoReg), 
    .Branch(Branch),
    .Jump(Jump)
    );


endmodule
