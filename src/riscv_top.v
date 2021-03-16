`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/20 21:43:14
// Design Name: 
// Module Name: riscv_top
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

module riscv_top(
    input clk,rst
    );

    wire [31:0] instr, instr_addr, rs2, dread_mem, result;
    wire instrmem_en, datamem_en, datamem_we;

    cpu cpu(
        .clk(clk),
        .rst(rst),
        .instr(instr), 
        .dread_mem(dread_mem),
        .result(result), 
        .instr_addr(instr_addr), 
        .rs2(rs2),
        .instrmem_en(instrmem_en),
        .datamem_en(datamem_en), 
        .datamem_we(datamem_we)
    );

    //instruction memory, as it is read only, we set dina 0 and disable the wea
    instr_mem instr_mem (
    .clka(~clk),    // input wire clka
    .ena(instrmem_en),      // input wire ena
    .wea(4'b0),      // input wire [3 : 0] wea
    .addra(instr_addr [7:0]),  // input wire [7 : 0] addra
    .dina(32'b0),    // input wire [31 : 0] dina
    .douta(instr)  // output wire [31 : 0] douta
    );

    //data_mem
    data_mem data_mem (
    .clka(~clk),    // input wire clka
    .ena(datamem_en),      // input wire ena
    .wea({4{datamem_we}}),      // input wire [3 : 0] wea
    .addra(result [9:0]),  // input wire [9 : 0] addra
    .dina(rs2),    // input wire [31 : 0] dina
    .douta(dread_mem)  // output wire [31 : 0] data read from data_mem
    );

endmodule
