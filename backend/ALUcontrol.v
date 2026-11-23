`timescale 1ns / 1ps

// ALUcontrol: din ALUop (de la unitatea de control) + funct3/funct7 alege operatia ALU (ALUinput, 4 biti)
//   ALUop = 00 -> lw, sw           : adunare (adresa = rs1 + imm)
//   ALUop = 01 -> branch           : comparatie (sub / slt / sltu, dupa funct3)
//   ALUop = 10 -> R-type           : operatia din funct3 + funct7
//   ALUop = 11 -> I-type (addi...) : operatia din funct3 (funct7 conteaza doar la srli/srai)
module ALUcontrol(input [1:0] ALUop,
                  input [6:0] funct7,
                  input [2:0] funct3,
                  output reg [3:0] ALUinput);

    localparam ALU_AND  = 4'b0000;
    localparam ALU_OR   = 4'b0001;
    localparam ALU_ADD  = 4'b0010;
    localparam ALU_XOR  = 4'b0011;
    localparam ALU_SLL  = 4'b0100;
    localparam ALU_SRL  = 4'b0101;
    localparam ALU_SUB  = 4'b0110;
    localparam ALU_SLTU = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SRA  = 4'b1001;

    always @(*) begin
        case (ALUop)
            2'b00: ALUinput = ALU_ADD;                                     // lw, sw

            2'b01: case (funct3)                                           // branch-uri
                       3'b000, 3'b001: ALUinput = ALU_SUB;                 // beq, bne   -> se uita la zero
                       3'b100, 3'b101: ALUinput = ALU_SLT;                 // blt, bge   -> se uita la out[0]
                       3'b110, 3'b111: ALUinput = ALU_SLTU;                // bltu, bgeu -> se uita la out[0]
                       default:        ALUinput = ALU_SUB;
                   endcase

            2'b10: case (funct3)                                           // R-type
                       3'b000:  ALUinput = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD;  // sub / add
                       3'b001:  ALUinput = ALU_SLL;                        // sll
                       3'b010:  ALUinput = ALU_SLT;                        // slt
                       3'b011:  ALUinput = ALU_SLTU;                       // sltu
                       3'b100:  ALUinput = ALU_XOR;                        // xor
                       3'b101:  ALUinput = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;  // sra / srl
                       3'b110:  ALUinput = ALU_OR;                         // or
                       3'b111:  ALUinput = ALU_AND;                        // and
                       default: ALUinput = ALU_ADD;
                   endcase

            2'b11: case (funct3)                                           // I-type aritmetice
                       3'b000:  ALUinput = ALU_ADD;                        // addi (nu exista subi!)
                       3'b001:  ALUinput = ALU_SLL;                        // slli
                       3'b010:  ALUinput = ALU_SLT;                        // slti
                       3'b011:  ALUinput = ALU_SLTU;                       // sltiu
                       3'b100:  ALUinput = ALU_XOR;                        // xori
                       3'b101:  ALUinput = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;  // srai / srli
                       3'b110:  ALUinput = ALU_OR;                         // ori
                       3'b111:  ALUinput = ALU_AND;                        // andi
                       default: ALUinput = ALU_ADD;
                   endcase

            default: ALUinput = ALU_ADD;
        endcase
    end

endmodule
