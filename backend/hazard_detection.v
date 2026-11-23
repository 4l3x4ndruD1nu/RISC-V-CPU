`timescale 1ns / 1ps

// Unitatea de detectie a hazardurilor (load-use).
// Daca instructiunea din EX este un lw (MemRead = 1) si scrie un registru pe care
// instructiunea din ID vrea sa-l citeasca, valoarea nu exista inca (vine abia din memorie),
// deci forwarding-ul nu ajunge -> oprim pipeline-ul un ciclu:
//   PCwrite = 0, IF_IDwrite = 0 (IF si ID raman pe loc), control_sel = 1 (in EX intra o bula).
module hazard_detection(input [4:0] rd,       //adresa registrului destinatie in etapa EX
                        input [4:0] rs1,      //adresa registrului sursa 1 decodificat in etapa ID
                        input [4:0] rs2,      //adresa registrului sursa 2 decodificat in etapa ID
                        input MemRead,        //semnalul de control MemRead din etapa EX
                        output reg PCwrite,   //semnalul PCwrite ce controleaza scrierea in registrul PC
                        output reg IF_IDwrite,//semnal ce controleaza scrierea in registrul de pipeline IF_ID
                        output reg control_sel); //semnal transmis spre unitatea de control

    always @(*) begin
        if (MemRead && ((rd == rs1) || (rd == rs2))) begin   // stall the pipeline
            PCwrite     = 1'b0;
            IF_IDwrite  = 1'b0;
            control_sel = 1'b1;
        end
        else begin
            PCwrite     = 1'b1;
            IF_IDwrite  = 1'b1;
            control_sel = 1'b0;
        end
    end

endmodule
