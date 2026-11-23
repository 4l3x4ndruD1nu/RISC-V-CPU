`timescale 1ns / 1ps

// Unitatea de control (control_path)
// Din opcode genereaza cele 7 semnale de control (8 biti):
//   WB : RegWrite, MemtoReg
//   M  : MemRead, MemWrite, Branch
//   EX : ALUop[1:0], ALUSrc
// control_sel vine de la hazard_detection: 1 = stall -> toate semnalele 0 (bula/NOP).
// Asta e MUX-ul cu intrarea "0" din Fig. 2.
module control_path(input [6:0] opcode,
                    input control_sel,
                    output reg RegWrite, MemtoReg,
                    output reg MemRead, MemWrite, Branch,
                    output reg [1:0] ALUop,
                    output reg ALUSrc);

    localparam R_TYPE = 7'b0110011;   // add, sub, and, or, xor, sll, srl, sra, slt, sltu
    localparam I_TYPE = 7'b0010011;   // addi, andi, ori, xori, slti, sltiu, slli, srli, srai
    localparam LOAD   = 7'b0000011;   // lw
    localparam STORE  = 7'b0100011;   // sw
    localparam BRANCH = 7'b1100011;   // beq, bne, blt, bge, bltu, bgeu

    // ordinea bitilor: {RegWrite, MemtoReg, MemRead, MemWrite, Branch, ALUop[1:0], ALUSrc}
    always @(*) begin
        if (control_sel)
            {RegWrite, MemtoReg, MemRead, MemWrite, Branch, ALUop, ALUSrc} = 8'b0;
        else
            case (opcode)
                R_TYPE:  {RegWrite, MemtoReg, MemRead, MemWrite, Branch, ALUop, ALUSrc} = 8'b1_0_0_0_0_10_0;
                I_TYPE:  {RegWrite, MemtoReg, MemRead, MemWrite, Branch, ALUop, ALUSrc} = 8'b1_0_0_0_0_11_1;
                LOAD:    {RegWrite, MemtoReg, MemRead, MemWrite, Branch, ALUop, ALUSrc} = 8'b1_1_1_0_0_00_1;
                STORE:   {RegWrite, MemtoReg, MemRead, MemWrite, Branch, ALUop, ALUSrc} = 8'b0_0_0_1_0_00_1;
                BRANCH:  {RegWrite, MemtoReg, MemRead, MemWrite, Branch, ALUop, ALUSrc} = 8'b0_0_0_0_1_01_0;
                default: {RegWrite, MemtoReg, MemRead, MemWrite, Branch, ALUop, ALUSrc} = 8'b0;  // NOP / necunoscut
            endcase
    end

endmodule
