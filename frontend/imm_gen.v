`timescale 1ns / 1ps;

module imm_gen(input [31:0] in, output reg [31:0] out);
    // i used localparam because it apparently cannot be modified by other modules
    // and that seems cool to me
    localparam OP_BEQ   = 7'b1100011;
    localparam OP_BNE   = 7'b1100011;
    localparam OP_BLT   = 7'b1100011;
    localparam OP_BGE   = 7'b1100011;
    localparam OP_BLTU  = 7'b1100011;
    localparam OP_BGEU  = 7'b1100011;
    
    localparam OP_LW    = 7'b0000011;
    localparam OP_SW    = 7'b0100011;
    
    localparam OP_ADDI  = 7'b0010011;
    localparam OP_SLTI  = 7'b0010011;
    localparam OP_SLTIU = 7'b0010011;
    localparam OP_XORI  = 7'b0010011;
    localparam OP_ORI   = 7'b0010011;
    localparam OP_ANDI  = 7'b0010011;
    localparam OP_SLLI  = 7'b0010011;
    localparam OP_SRLI  = 7'b0010011;
    localparam OP_SRAI  = 7'b0010011;
    
    
    wire [6:0] opcode;
    assign opcode = in[6:0];    
    
    // @RISC-V spec v2.2
    // see pag 12 figures 2.3 for instr types and 2.4 for their immediates
    // and pag 104 for the instruction set and immediate mapping
    // (god help us all)
    always @(*) begin
        case (opcode)
            // B-type
            OP_BEQ, OP_BNE, OP_BLT, OP_BGE, OP_BLTU, OP_BGEU: begin
                out = { {19{in[31]}}, in[31], in[7], in[30:25], in[11:8], 1'b0 };
            end
            
            // I-type
            OP_LW, OP_ADDI, OP_SLTI, OP_SLTIU, OP_XORI, OP_ORI, OP_ANDI, OP_SLLI, OP_SRLI, OP_SRAI: begin
                out = { {21{in[31]}}, in[30:25], in[24:21], in[20] };
            end
            
            // S-type
            OP_SW: begin
                out = { {21{in[31]}}, in[30:25], in[11:8], in[7] };
            end
            
            default: begin
                out = 32'b0;
            end
        endcase
    end

endmodule