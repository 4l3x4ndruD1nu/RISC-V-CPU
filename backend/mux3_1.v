`timescale 1ns / 1ps

// Multiplexor 3:1 pentru forwarding
//   sel = 00 -> ina (valoarea citita in ID, din ID/EX)
//   sel = 01 -> inb (valoarea din WB)
//   sel = 10 -> inc (rezultatul ALU din MEM)
module mux3_1(input [31:0] ina, inb, inc,
              input [1:0] sel,
              output reg [31:0] out);

    always @(*) begin
        case (sel)
            2'b01:   out = inb;
            2'b10:   out = inc;
            default: out = ina;     // 00 (si 11, nefolosit)
        endcase
    end

endmodule
