`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/20 15:47:20
// Design Name: 
// Module Name: datapath
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

module datapath(
    input clk,rst,
    input RegWrite, ALUSrc, MemtoReg, Branch, MemRead, MemWrite,
    input [3:0] aluctrl,
    input [31:0] instr, dread_mem,
    output datamem_en, datamem_we,  //in single cycle CPU, the two signals are outputs of controller while are outputs of control register in EX/MEM in pipeline
    output [31:0] result_EX, instr_addr, rs2_EX, IR_IF   //in a pipeline, IR is also connected to main decoder, so it is an output
    );

    wire [31:0] pc_increment4, pc_next, pc_branch, result, rs2;
    wire [31:0] imm, ALUSrca, ALUSrcb, dwrite_regfile;
    //wire [31:0] PCoffset;
    wire zero, PCSrc;
    //define the virables used for registers at the end of each stage to store intermediate data
    wire [31:0] pc_IF;
    wire [31:0] read1_ID, read2_ID, imm_ID, pc_ID;
    wire [4:0] wdst_ID;
    wire [4:0] wdst_EX;
    wire [31:0] result_MEM, dread_mem_MEM;
    wire [4:0] wdst_MEM;
    // define control signals  connected to the control portions of the pipeline registers
    wire [9:0] control_ID;
    wire [4:0] control_EX;
    wire [1:0] control_MEM;
    // used for forwarding
    wire [4:0] rs1_ID, rs2_ID;
    wire [1:0] forwardA, forwardB;
    wire [31:0] ina, inb;
    //used for RAW hazard detection
    wire PCWriteb, IDWriteb, CtrlSrcb;
    wire [9:0] control_out;
    //used for control hazards
    wire IF_flush;
    wire PCWritea, IDWritea, CtrlSrca;
    wire [31:0] branch_rs1, branch_rs2, branch_forwardA, branch_forwardB;

    //active components in IF stage(except write the new PC, i.e., target PC and control signal PCSrc are from registers in EX/MEM)
    //mux:select next instruction address to be writen to PC
    mux2_1 mux2(
    .a(pc_increment4),
    .b(pc_branch),
    .sel(PCSrc),    //control signal: branch,decide the next pc 
    .out(pc_next)
    );

    //pc
    register pc (
    .clk(clk),
    .load(PCWritea && PCWriteb),
    .rst(rst),
    .clear(1'b0),
    .in(pc_next),
    .out(instr_addr)
    );

    //pc increment
    adder #(32) adder1
    (.a(32'b1),
     .b(instr_addr),
     .s(pc_increment4)
    );

    assign IF_flush = PCSrc;
    // 2 registers in IF/ID stage
    register IRIF (
    .clk(clk),
    .load(IDWritea && IDWriteb),
    .rst(rst),
    .clear(IF_flush),
    .in(instr),
    .out(IR_IF)
    );

    register pcIF (
    .clk(clk),
    .load(IDWritea && IDWriteb),
    .rst(rst),
    .clear(1'b0),
    .in(instr_addr),
    .out(pc_IF)
    );
    
    //----------------------------------------------------------------------------------------------------
    //active components in ID stage(except for regfile write, i.e., write_data and control signal we are from registers in MEM/WB) 
    //register file
    regfile regfile (
    .clk(clk),
    .we(control_MEM[0]),    //control signal:RegWrite
    .read1(IR_IF [19:15]), 
    .read2(IR_IF [24:20]), 
    .write(wdst_MEM),
    .write_data(dwrite_regfile),
    .data_out1(ALUSrca), 
    .data_out2(rs2)
    );
   
    //sign-extend
    signext signext 
    (.instr(IR_IF),
     .imm(imm)
    );

    //in this architecture, the instr memery is word-addressable. Thus, the pc increments by 1 and left shift is not needed.
    /*shiftleft shiftleft1(
    .imm(imm),
    .offset(PCoffset)
    );*/
    
    // data forwarding for branch
    branchForwarding branchForwarding(
    .rs1          ( IR_IF [19:15]   ),
    .rs2          ( IR_IF [24:20]   ),
    .rd_EX        ( wdst_EX        ),
    .rd_MEM       ( wdst_MEM       ),
    .RegWrite_EX  ( control_EX[0]  ),
    .MemRead_EX   (control_EX[3]),
    .RegWrite_MEM ( control_MEM[0] ),
    .branch_forwardA     ( branch_forwardA     ),
    .branch_forwardB     ( branch_forwardB     )
    );

    mux4_1 branch_muxA(
    .a   ( result_EX   ),
    .b   ( dwrite_regfile   ),
    .c   (  ALUSrca  ),
    .sel ( branch_forwardA ),
    .out  ( branch_rs1 )
    );

    mux4_1 branch_muxB(
    .a   ( result_EX   ),
    .b   ( dwrite_regfile   ),
    .c   (  rs2  ),
    .sel ( branch_forwardB ),
    .out  ( branch_rs2 )
    );

    branchhazardDetection branchhazardDetection(
    .rs1     ( IR_IF [19:15]     ),
    .rs2     ( IR_IF [24:20]     ),
    .rd_ID   ( wdst_ID   ),
    .rd_EX   ( wdst_EX   ),
    .Branch  (Branch),
    .MemRead ( control_EX[3] ),
    .PCWrite ( PCWritea ),
    .IDWrite ( IDWritea ),
    .CtrlSrc  ( CtrlSrca  )
    );


    assign PCSrc = Branch ? (branch_rs1 - branch_rs2 == 0) : 0;
    
    //calculate the target PC address
    adder #(32) adder2   
    (.a(imm),
     .b(pc_IF),
     .s(pc_branch)
    );


    hazardDetection hazardDetection(
    .rs1     ( IR_IF [19:15] ),
    .rs2     ( IR_IF [24:20] ),
    .rd      ( wdst_ID      ),
    .MemRead ( control_ID[3] ),
    .PCWrite ( PCWriteb ),
    .IDWrite ( IDWriteb ),
    .CtrlSrc ( CtrlSrcb  )
    );

    mux2_1 #(10) muxbubble(
    .a({aluctrl, ALUSrc, Branch, MemRead, MemWrite, MemtoReg, RegWrite}),
    .b(10'b0),
    .sel(CtrlSrca || CtrlSrcb),    //control signal: decide the control signals 
    .out(control_out)
    );

    //6 registers in IF/ID stage
    register read1ID (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(ALUSrca),
    .out(read1_ID)
    );

    register read2ID (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(rs2),
    .out(read2_ID)
    );

    register #(5) wdstID (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(Branch),  //corner case: rd field in branch is imm[4:1],11 , 
                     //when there is a stall in branch, it will lead to another stall.
    .in(IR_IF [11:7]),
    .out(wdst_ID)
    );

    register immID (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(imm),
    .out(imm_ID)
    );

    register pcID (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(pc_IF),
    .out(pc_ID)
    );

    register #(10) controlID (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(control_out),
    .out(control_ID)
    );
    
    //To be compared to rd field in forwarding unit, rs1, rs2 field in instruction need to be saved to ID/EX registers
    register #(5) rs1ID (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(IR_IF [19:15]),
    .out(rs1_ID)
    );

    register #(5) rs2ID (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(IR_IF [24:20]),
    .out(rs2_ID)
    );
    //---------------------------------------------------------------------------------------------------------
    //active components in EX stage
    
    //mux:select ALU Src
    mux2_1 mux1(
    .a(inb),
    .b(imm_ID),
    .sel(control_ID[5]),    //control signal:ALUSrc
    .out(ALUSrcb)
    );

    //ALU
    alu #(32) alu
    (
    .a(ina),
    .b(ALUSrcb),
    .ALUctrl(control_ID[9:6]),   //control signal:ALUControl 
    .result(result),
    .zero(zero)
    );

    // data forwarding
    forwarding_unit forwarding_unit(
    .rs1          ( rs1_ID          ),
    .rs2          ( rs2_ID          ),
    .rd_EX        ( wdst_EX        ),
    .rd_MEM       ( wdst_MEM       ),
    .RegWrite_EX  ( control_EX[0]  ),
    .RegWrite_MEM ( control_MEM[0] ),
    .forwardA     ( forwardA     ),
    .forwardB     ( forwardB     )
    );

    mux4_1 muxA(
    .a   ( result_EX   ),
    .b   ( dwrite_regfile   ),
    .c   (  read1_ID  ),
    .sel ( forwardA ),
    .out  ( ina )
    );

    mux4_1 muxB(
    .a   ( result_EX   ),
    .b   ( dwrite_regfile   ),
    .c   (  read2_ID  ),
    .sel ( forwardB ),
    .out  ( inb )
    );

    // 4 registers in EX/MEM stage
    register resultEX (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(result),
    .out(result_EX)
    );

    register rs2EX (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(read2_ID),
    .out(rs2_EX)
    );

    register #(5) wdstEX (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(wdst_ID),
    .out(wdst_EX)
    );
 
    register #(5) controlEX (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(control_ID[4:0]),
    .out(control_EX)
    );

    //-------------------------------------------------------------------------------------------------------------------
    //active components in MEM stage
    //3 registers in EX/MEM stage
    register resultMEM (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(result_EX),
    .out(result_MEM)
    );

    register #(5) wdstMEM (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(wdst_EX),
    .out(wdst_MEM)
    );

    register dread_memMEM (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(dread_mem),
    .out(dread_mem_MEM)
    );

    //signals to control the data memory
    /*register #(1) MemReadMEM (
    .clk(clk),
    .rst(rst),
    .clear(1'b0),
    .in(control_EX[3]),
    .out(MemRead)
    );

    register #(1)MemWriteMEM (
    .clk(clk),
    .rst(rst),
    .clear(1'b0),
    .in(control_EX[2]),
    .out(MemWrite)
    );*/

    assign datamem_en = control_EX[3];
    assign datamem_we = control_EX[2];

    register #(2) controlMEM (
    .clk(clk),
    .load(1'b1),
    .rst(rst),
    .clear(1'b0),
    .in(control_EX[1:0]),
    .out(control_MEM)
    );


    //-------------------------------------------------------------------------------------------------------------------
    //active components in WB stage
    //mux: select the result to be written to register file
    mux2_1 mux3(
    .a(result_MEM),
    .b(dread_mem_MEM),
    .sel(control_MEM[1]),    //control signal:MemtoReg   
    .out(dwrite_regfile)
    );




    
endmodule