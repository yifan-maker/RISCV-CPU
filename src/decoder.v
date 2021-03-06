`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/17 18:33:54
// Design Name: 
// Module Name: decoder
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

module alu_control (
    input [1:0] ALUOp,
    input funct7,  //given the 4 R-type instructions, add, subtract, and, or, we implemented, only bit 30 in funct7 field is different
    input [2:0] funct3,
    output reg [3:0] aluctrl
);
    always @(*) begin
        casez ({ALUOp,funct7,funct3})
            6'b00_????: aluctrl = 2'b0010;  //lw,sw add
            6'b?1_????: aluctrl = 2'b0110;  //beq, sub
            6'b10_0000: aluctrl = 2'b0010;  //add
            6'b10_1000: aluctrl = 2'b0110;  //sub
            6'b10_0111: aluctrl = 2'b0000;  //and
            6'b10_0110: aluctrl = 2'b0001;  //or
            default: aluctrl = 2'b0000;
        endcase
    end    
endmodule

module main_control (
    input [6:0] opcode,
    output reg [1:0] ALUOp,
    output reg RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch
);
    always @(opcode) begin
        case (opcode)
            2'b011_0011: {ALUOp, RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch} = 2'b1010_0000; //R-type
            2'b000_0011: {ALUOp, RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch} = 2'b0011_0110; //I-type lw
            2'b010_0011: {ALUOp, RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch} = 2'b0000_1100; //S-type sw
            2'b110_0011: {ALUOp, RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch} = 2'b0100_0001; //B-type beq
            default: {ALUOp, RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch} = 2'b0000_0000;
        endcase
    end
    
endmodule

module decoder(
    input [31:0] instr,
    output [3:0] aluctrl,
    output RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch
    );
    wire [1:0] op;
    main_control MainControlUnit(
    .opcode (instr [6:0]),
    .ALUOp (op),
    .RegWrite (RegWrite), .MemRead (MemRead), .MemWrite (MemWrite), .ALUSrc (ALUSrc), .MemtoReg (MemtoReg), .Branch (Branch)
    );

    alu_control  ALUControlUnit(
    .ALUOp (op),
    .funct7 (instr [31:25]),  //given the 4 R-type instructions, add, subtract, and, or, we implemented, only bit 30 in funct7 field is different
    .funct3 (instr [14:12]),
    .aluctrl (aluctrl)
    ); 
endmodule
