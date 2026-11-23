`timescale 1ns / 1ps

// Etapa EX: forwarding mux-uri, mux ALUSrc, ALUcontrol, ALU si sumatorul pentru adresa de salt.
// RD/RS si semnalele de control WB/M intra aici ca in cerinta, dar sunt folosite doar in top
// (merg mai departe in EX/MEM, respectiv in unitatea de forwarding).
module EX(input [31:0] IMM_EX,         //valoarea imediata in EX
          input [31:0] REG_DATA1_EX,   //valoarea registrului sursa 1
          input [31:0] REG_DATA2_EX,   //valoarea registrului sursa 2
          input [31:0] PC_EX,          //adresa instructiunii curente in EX
          input [2:0] FUNCT3_EX,       //funct3 pentru instructiunea din EX
          input [6:0] FUNCT7_EX,       //funct7 pentru instructiunea din EX
          input [4:0] RD_EX,           //adresa registrului destinatie
          input [4:0] RS1_EX,          //adresa registrului sursa 1
          input [4:0] RS2_EX,          //adresa registrului sursa 2
          input RegWrite_EX,           //semnal de scriere in bancul de registri
          input MemtoReg_EX,           //semnal de selectie ALU/memorie in WB
          input MemRead_EX,            //semnal pentru activarea citirii din memorie
          input MemWrite_EX,           //semnal pentru activarea scrierii in memorie
          input [1:0] ALUop_EX,        //semnalul de control ALUop
          input ALUSrc_EX,             //semnal de selectie intre RS2 si valoarea imediata
          input Branch_EX,             //semnal de identificare a instructiunilor de tip branch
          input [1:0] forwardA, forwardB, //semnalele de selectie pentru multiplexoarele de forwarding

          input [31:0] ALU_DATA_WB,    //valoarea calculata de ALU, prezenta in WB
          input [31:0] ALU_OUT_MEM,    //valoarea calculata de ALU, prezenta in MEM

          output ZERO_EX,              //flag-ul ZERO calculat de ALU
          output [31:0] ALU_OUT_EX,    //rezultatul calculat de ALU in EX
          output [31:0] PC_Branch_EX,  //adresa de salt calculata in EX
          output [31:0] REG_DATA2_EX_FINAL //valoarea registrului sursa 2 selectata dintre
          );                               //valorile prezente in etapele EX, MEM si WB

    wire [31:0] ALU_Source1;   // operandul A dupa forwarding
    wire [31:0] MUX_B_temp;    // operandul B dupa forwarding (inainte de ALUSrc)
    wire [31:0] ALU_Source2;   // operandul B final (registru sau imediat)
    wire [3:0]  ALU_Control;   // ALUinput

    // forwarding: 00 = din ID/EX, 01 = din WB, 10 = din MEM
    mux3_1 MUX_FORWARD_A(.ina(REG_DATA1_EX), .inb(ALU_DATA_WB), .inc(ALU_OUT_MEM),
                         .sel(forwardA), .out(ALU_Source1));

    mux3_1 MUX_FORWARD_B(.ina(REG_DATA2_EX), .inb(ALU_DATA_WB), .inc(ALU_OUT_MEM),
                         .sel(forwardB), .out(MUX_B_temp));

    // ALUSrc: 0 = rs2 (R-type, branch), 1 = imediat (I-type, lw, sw)
    mux2_1 MUX_ALU_SOURCE2(.ina(MUX_B_temp), .inb(IMM_EX), .sel(ALUSrc_EX), .out(ALU_Source2));

    ALUcontrol ALU_CONTROL(.ALUop(ALUop_EX), .funct7(FUNCT7_EX), .funct3(FUNCT3_EX),
                           .ALUinput(ALU_Control));

    ALU ALU_UNIT(.ALUop(ALU_Control), .ina(ALU_Source1), .inb(ALU_Source2),
                 .zero(ZERO_EX), .out(ALU_OUT_EX));

    // adresa de salt = PC-ul instructiunii + imediat (shift left 1 e deja facut in imm_gen)
    adder BRANCH_ADDER(.ina(PC_EX), .inb(IMM_EX), .out(PC_Branch_EX));

    // pentru sw: valoarea de scris in memorie (rs2), tot dupa forwarding
    assign REG_DATA2_EX_FINAL = MUX_B_temp;

endmodule
