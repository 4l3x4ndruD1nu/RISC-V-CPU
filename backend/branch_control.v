`timescale 1ns / 1ps

// Branch Control (etapa MEM): decide daca saltul se face (PCSrc = 1).
// Pentru beq/bne ALU a facut sub -> ne uitam la zero.
// Pentru blt/bge (slt) si bltu/bgeu (sltu) ne uitam la bitul 0 al rezultatului.
module branch_control(input Branch,           //BRANCH_MEM: instructiunea din MEM e branch
                      input [2:0] funct3,     //FUNCT3_MEM: ce fel de branch
                      input zero,             //ZERO_MEM
                      input [31:0] alu_out,   //ALU_OUT_MEM
                      output reg PCSrc);      //1 = PC <- adresa de salt

    always @(*) begin
        PCSrc = 1'b0;
        if (Branch) begin
            case (funct3)
                3'b000:  PCSrc = zero;          // beq
                3'b001:  PCSrc = ~zero;         // bne
                3'b100:  PCSrc = alu_out[0];    // blt
                3'b101:  PCSrc = ~alu_out[0];   // bge
                3'b110:  PCSrc = alu_out[0];    // bltu
                3'b111:  PCSrc = ~alu_out[0];   // bgeu
                default: PCSrc = 1'b0;
            endcase
        end
    end

endmodule
