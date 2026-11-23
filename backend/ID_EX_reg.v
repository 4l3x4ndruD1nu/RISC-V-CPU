`timescale 1ns / 1ps

// Registrul de pipeline ID/EX: semnalele de control (WB, M, EX) + datele instructiunii din ID.
module ID_EX_reg(input clk, res, write,
                 // control
                 input RegWrite_in, MemtoReg_in,                  // WB
                 input MemRead_in, MemWrite_in, Branch_in,        // M
                 input [1:0] ALUop_in,                            // EX
                 input ALUSrc_in,                                 // EX
                 // date
                 input [31:0] PC_in,
                 input [2:0]  func3_in,
                 input [6:0]  func7_in,
                 input [31:0] ALU_A_in, ALU_B_in,                 // REG_DATA1_ID, REG_DATA2_ID
                 input [4:0]  RS1_in, RS2_in, RD_in,
                 input [31:0] IMM_in,

                 output reg RegWrite_out, MemtoReg_out,
                 output reg MemRead_out, MemWrite_out, Branch_out,
                 output reg [1:0] ALUop_out,
                 output reg ALUSrc_out,
                 output reg [31:0] PC_out,
                 output reg [2:0]  func3_out,
                 output reg [6:0]  func7_out,
                 output reg [31:0] ALU_A_out, ALU_B_out,
                 output reg [4:0]  RS1_out, RS2_out, RD_out,
                 output reg [31:0] IMM_out);

    always @(posedge clk or posedge res) begin
        if (res) begin
            {RegWrite_out, MemtoReg_out}               <= 2'b0;
            {MemRead_out, MemWrite_out, Branch_out}    <= 3'b0;
            ALUop_out  <= 2'b0;
            ALUSrc_out <= 1'b0;
            PC_out     <= 32'b0;
            func3_out  <= 3'b0;
            func7_out  <= 7'b0;
            ALU_A_out  <= 32'b0;
            ALU_B_out  <= 32'b0;
            RS1_out    <= 5'b0;
            RS2_out    <= 5'b0;
            RD_out     <= 5'b0;
            IMM_out    <= 32'b0;
        end
        else if (write) begin
            RegWrite_out <= RegWrite_in;
            MemtoReg_out <= MemtoReg_in;
            MemRead_out  <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            Branch_out   <= Branch_in;
            ALUop_out    <= ALUop_in;
            ALUSrc_out   <= ALUSrc_in;
            PC_out       <= PC_in;
            func3_out    <= func3_in;
            func7_out    <= func7_in;
            ALU_A_out    <= ALU_A_in;
            ALU_B_out    <= ALU_B_in;
            RS1_out      <= RS1_in;
            RS2_out      <= RS2_in;
            RD_out       <= RD_in;
            IMM_out      <= IMM_in;
        end
    end

endmodule
