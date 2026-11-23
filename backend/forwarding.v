`timescale 1ns / 1ps

// Unitatea de forwarding: rezolva hazardurile RAW fara stall, aducand rezultatul
// direct din MEM sau din WB, inainte sa fie scris in bancul de registri.
//   forwardX = 10 -> din EX/MEM (instructiunea imediat anterioara)   = hazard in EX
//   forwardX = 01 -> din MEM/WB (instructiunea de acum 2 cicluri)    = hazard in MEM
//   forwardX = 00 -> valoarea citita normal in ID
// Ordinea if / else if da prioritate lui EX/MEM (valoarea cea mai noua). Asta e exact
// conditia "and not(EX/MEM.RegWrite and ...)" din pseudocodul pentru hazardul in MEM.
module forwarding(input [4:0] rs1,           //adresa registrului sursa 1 in etapa EX
                  input [4:0] rs2,           //adresa registrului sursa 2 in etapa EX
                  input [4:0] ex_mem_rd,     //adresa registrului destinatie in etapa MEM
                  input [4:0] mem_wb_rd,     //adresa registrului destinatie in etapa WB
                  input ex_mem_regwrite,     //semnalul de control RegWrite in etapa MEM
                  input mem_wb_regwrite,     //semnalul de control RegWrite in etapa WB
                  output reg [1:0] forwardA, forwardB); //semnalele de selectie a multiplexoarelor
                                                        //ce vor alege valoarea ce trebuie bypassata
    always @(*) begin
        // operandul A (rs1)
        if (ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == rs1))
            forwardA = 2'b10;
        else if (mem_wb_regwrite && (mem_wb_rd != 5'b0) && (mem_wb_rd == rs1))
            forwardA = 2'b01;
        else
            forwardA = 2'b00;

        // operandul B (rs2)
        if (ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == rs2))
            forwardB = 2'b10;
        else if (mem_wb_regwrite && (mem_wb_rd != 5'b0) && (mem_wb_rd == rs2))
            forwardB = 2'b01;
        else
            forwardB = 2'b00;
    end

endmodule
