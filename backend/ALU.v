`timescale 1ns / 1ps

// ALU pe 32 de biti. Codurile ALUop sunt cele din tabelul de la cerinta 1 (ALUinput).
module ALU(input [3:0] ALUop,          //ALUinput ce selecteaza operatia
           input [31:0] ina, inb,      //operanzii ce iau parte la operatie
           output zero,                //semnal ce verifica daca rezultatul este 0
           output reg [31:0] out);     //rezultatul operatiei

    always @(*) begin
        case (ALUop)
            4'b0000: out = ina & inb;                                     // and
            4'b0001: out = ina | inb;                                     // or
            4'b0010: out = ina + inb;                                     // add
            4'b0011: out = ina ^ inb;                                     // xor
            4'b0100: out = ina << inb[4:0];                               // sll (doar 5 biti de shift)
            4'b0101: out = ina >> inb[4:0];                               // srl (intra zerouri)
            4'b0110: out = ina - inb;                                     // sub
            4'b0111: out = (ina < inb) ? 32'd1 : 32'd0;                   // sltu (fara semn)
            4'b1000: out = ($signed(ina) < $signed(inb)) ? 32'd1 : 32'd0; // slt  (cu semn)
            4'b1001: out = $signed(ina) >>> inb[4:0];                     // sra (se copiaza bitul de semn)
            default: out = 32'b0;
        endcase
    end

    assign zero = (out == 32'b0);

endmodule
