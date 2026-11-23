`timescale 1ns / 1ps

// Procesorul RISC-V complet: 5 etape de pipeline + hazard detection + forwarding.
// Numele instantelor sunt aceleasi ca in ierarhia din cerinta (RV -> instruction_fetch, ...).
module RISC_V(input clk,                       //semnalul de ceas global
              input reset,                     //semnalul de reset global

              output [31:0] PC_EX,             //adresa PC in etapa EX
              output [31:0] ALU_OUT_EX,        //valoarea calculata de ALU in etapa EX
              output [31:0] PC_MEM,            //adresa de salt calculata
              output PCSrc,                    //semnal de selectie pentru PC
              output [31:0] DATA_MEMORY_MEM,   //valoarea citita din memoria de date in MEM
              output [31:0] ALU_DATA_WB,       //valoarea finala scrisa in etapa WB
              output [1:0] forwardA, forwardB, //semnalele de forwarding
              output pipeline_stall            //semnal de stall la detectia de hazarduri
              );

    // ------------------------------------------------------------------ fire
    // IF
    wire [31:0] PC_IF, INSTRUCTION_IF;
    wire PC_write, IF_ID_write;                      // de la hazard_detection
    // ID
    wire [31:0] PC_ID, INSTRUCTION_ID;
    wire [31:0] IMM_ID, REG_DATA1_ID, REG_DATA2_ID;
    wire [2:0]  FUNCT3_ID;
    wire [6:0]  FUNCT7_ID, OPCODE_ID;
    wire [4:0]  RD_ID, RS1_ID, RS2_ID;
    wire RegWrite_ID, MemtoReg_ID, MemRead_ID, MemWrite_ID, Branch_ID, ALUSrc_ID;
    wire [1:0]  ALUop_ID;
    // EX
    wire [31:0] IMM_EX, REG_DATA1_EX, REG_DATA2_EX;
    wire [2:0]  FUNCT3_EX;
    wire [6:0]  FUNCT7_EX;
    wire [4:0]  RD_EX, RS1_EX, RS2_EX;
    wire RegWrite_EX, MemtoReg_EX, MemRead_EX, MemWrite_EX, Branch_EX, ALUSrc_EX;
    wire [1:0]  ALUop_EX;
    wire ZERO_EX;
    wire [31:0] PC_Branch_EX, REG_DATA2_EX_FINAL;
    // MEM
    wire RegWrite_MEM, MemtoReg_MEM, MemRead_MEM, MemWrite_MEM, Branch_MEM;
    wire [2:0]  FUNCT3_MEM;
    wire ZERO_MEM;
    wire [31:0] ALU_OUT_MEM, REG_DATA2_MEM;
    wire [4:0]  RD_MEM;
    // WB
    wire RegWrite_WB, MemtoReg_WB;
    wire [31:0] DATA_MEMORY_WB, ALU_OUT_WB;
    wire [4:0]  RD_WB;

    // ------------------------------------------------------------------ IF
    IF instruction_fetch(.clk(clk), .reset(reset),
                         .PCSrc(PCSrc), .PC_write(PC_write),
                         .PC_Branch(PC_MEM),               // adresa de salt vine din MEM
                         .PC_IF(PC_IF), .INSTRUCTION_IF(INSTRUCTION_IF));

    IF_ID_reg IF_ID_REGISTER(.clk(clk), .res(reset), .write(IF_ID_write),
                             .pc_in(PC_IF), .instruction_in(INSTRUCTION_IF),
                             .pc_out(PC_ID), .instruction_out(INSTRUCTION_ID));

    // ------------------------------------------------------------------ ID
    ID instruction_decode(.clk(clk),
                          .PC_ID(PC_ID), .INSTRUCTION_ID(INSTRUCTION_ID),
                          .RegWrite_WB(RegWrite_WB), .ALU_DATA_WB(ALU_DATA_WB), .RD_WB(RD_WB),
                          .control_sel(pipeline_stall),
                          .IMM_ID(IMM_ID),
                          .REG_DATA1_ID(REG_DATA1_ID), .REG_DATA2_ID(REG_DATA2_ID),
                          .FUNCT3_ID(FUNCT3_ID), .FUNCT7_ID(FUNCT7_ID), .OPCODE_ID(OPCODE_ID),
                          .RD_ID(RD_ID), .RS1_ID(RS1_ID), .RS2_ID(RS2_ID),
                          .RegWrite_ID(RegWrite_ID), .MemtoReg_ID(MemtoReg_ID),
                          .MemRead_ID(MemRead_ID), .MemWrite_ID(MemWrite_ID), .Branch_ID(Branch_ID),
                          .ALUop_ID(ALUop_ID), .ALUSrc_ID(ALUSrc_ID));

    hazard_detection HAZARD_DETECTION_UNIT(.rd(RD_EX), .rs1(RS1_ID), .rs2(RS2_ID),
                                           .MemRead(MemRead_EX),
                                           .PCwrite(PC_write), .IF_IDwrite(IF_ID_write),
                                           .control_sel(pipeline_stall));

    ID_EX_reg ID_EX_REGISTER(.clk(clk), .res(reset), .write(1'b1),
                             .RegWrite_in(RegWrite_ID), .MemtoReg_in(MemtoReg_ID),
                             .MemRead_in(MemRead_ID), .MemWrite_in(MemWrite_ID), .Branch_in(Branch_ID),
                             .ALUop_in(ALUop_ID), .ALUSrc_in(ALUSrc_ID),
                             .PC_in(PC_ID), .func3_in(FUNCT3_ID), .func7_in(FUNCT7_ID),
                             .ALU_A_in(REG_DATA1_ID), .ALU_B_in(REG_DATA2_ID),
                             .RS1_in(RS1_ID), .RS2_in(RS2_ID), .RD_in(RD_ID), .IMM_in(IMM_ID),
                             .RegWrite_out(RegWrite_EX), .MemtoReg_out(MemtoReg_EX),
                             .MemRead_out(MemRead_EX), .MemWrite_out(MemWrite_EX), .Branch_out(Branch_EX),
                             .ALUop_out(ALUop_EX), .ALUSrc_out(ALUSrc_EX),
                             .PC_out(PC_EX), .func3_out(FUNCT3_EX), .func7_out(FUNCT7_EX),
                             .ALU_A_out(REG_DATA1_EX), .ALU_B_out(REG_DATA2_EX),
                             .RS1_out(RS1_EX), .RS2_out(RS2_EX), .RD_out(RD_EX), .IMM_out(IMM_EX));

    // ------------------------------------------------------------------ EX
    forwarding FORWARDING_UNIT(.rs1(RS1_EX), .rs2(RS2_EX),
                               .ex_mem_rd(RD_MEM), .mem_wb_rd(RD_WB),
                               .ex_mem_regwrite(RegWrite_MEM), .mem_wb_regwrite(RegWrite_WB),
                               .forwardA(forwardA), .forwardB(forwardB));

    EX execute(.IMM_EX(IMM_EX), .REG_DATA1_EX(REG_DATA1_EX), .REG_DATA2_EX(REG_DATA2_EX),
               .PC_EX(PC_EX), .FUNCT3_EX(FUNCT3_EX), .FUNCT7_EX(FUNCT7_EX),
               .RD_EX(RD_EX), .RS1_EX(RS1_EX), .RS2_EX(RS2_EX),
               .RegWrite_EX(RegWrite_EX), .MemtoReg_EX(MemtoReg_EX),
               .MemRead_EX(MemRead_EX), .MemWrite_EX(MemWrite_EX),
               .ALUop_EX(ALUop_EX), .ALUSrc_EX(ALUSrc_EX), .Branch_EX(Branch_EX),
               .forwardA(forwardA), .forwardB(forwardB),
               .ALU_DATA_WB(ALU_DATA_WB), .ALU_OUT_MEM(ALU_OUT_MEM),
               .ZERO_EX(ZERO_EX), .ALU_OUT_EX(ALU_OUT_EX),
               .PC_Branch_EX(PC_Branch_EX), .REG_DATA2_EX_FINAL(REG_DATA2_EX_FINAL));

    EX_MEM_reg EX_MEM_REGISTER(.clk(clk), .res(reset), .write(1'b1),
                               .RegWrite_in(RegWrite_EX), .MemtoReg_in(MemtoReg_EX),
                               .MemRead_in(MemRead_EX), .MemWrite_in(MemWrite_EX), .Branch_in(Branch_EX),
                               .pc_in(PC_Branch_EX), .func3_in(FUNCT3_EX), .zero_in(ZERO_EX),
                               .ALU_in(ALU_OUT_EX), .reg2_data_in(REG_DATA2_EX_FINAL), .rd_in(RD_EX),
                               .RegWrite_out(RegWrite_MEM), .MemtoReg_out(MemtoReg_MEM),
                               .MemRead_out(MemRead_MEM), .MemWrite_out(MemWrite_MEM), .Branch_out(Branch_MEM),
                               .pc_out(PC_MEM), .func3_out(FUNCT3_MEM), .zero_out(ZERO_MEM),
                               .alu_out(ALU_OUT_MEM), .reg2_data_out(REG_DATA2_MEM), .rd_out(RD_MEM));

    // ------------------------------------------------------------------ MEM
    data_memory DATA_MEMORY(.clk(clk), .mem_read(MemRead_MEM), .mem_write(MemWrite_MEM),
                            .address(ALU_OUT_MEM), .write_data(REG_DATA2_MEM),
                            .read_data(DATA_MEMORY_MEM));

    branch_control BRANCH_CONTROL(.Branch(Branch_MEM), .funct3(FUNCT3_MEM),
                                  .zero(ZERO_MEM), .alu_out(ALU_OUT_MEM),
                                  .PCSrc(PCSrc));

    MEM_WB_reg MEM_WB_REGISTER(.clk(clk), .res(reset), .write(1'b1),
                               .RegWrite_in(RegWrite_MEM), .MemtoReg_in(MemtoReg_MEM),
                               .data_in(DATA_MEMORY_MEM), .alu_in(ALU_OUT_MEM), .rd_in(RD_MEM),
                               .RegWrite_out(RegWrite_WB), .MemtoReg_out(MemtoReg_WB),
                               .data_out(DATA_MEMORY_WB), .alu_out(ALU_OUT_WB), .rd_out(RD_WB));

    // ------------------------------------------------------------------ WB
    // MemtoReg = 0 -> rezultatul ALU, MemtoReg = 1 -> valoarea citita din memorie (lw)
    mux2_1 MUX_ALU_DATA(.ina(ALU_OUT_WB), .inb(DATA_MEMORY_WB), .sel(MemtoReg_WB), .out(ALU_DATA_WB));

endmodule
