`timescale 1ns / 1ps

// Registrul de pipeline EX/MEM: control (WB, M) + rezultatele etapei EX.
module EX_MEM_reg(input clk, res, write,
                  // control
                  input RegWrite_in, MemtoReg_in,                 // WB
                  input MemRead_in, MemWrite_in, Branch_in,       // M
                  // date
                  input [31:0] pc_in,                             // PC_Branch_EX
                  input [2:0]  func3_in,
                  input zero_in,
                  input [31:0] ALU_in,
                  input [31:0] reg2_data_in,                      // REG_DATA2_EX_FINAL (pentru sw)
                  input [4:0]  rd_in,

                  output reg RegWrite_out, MemtoReg_out,
                  output reg MemRead_out, MemWrite_out, Branch_out,
                  output reg [31:0] pc_out,
                  output reg [2:0]  func3_out,
                  output reg zero_out,
                  output reg [31:0] alu_out,
                  output reg [31:0] reg2_data_out,
                  output reg [4:0]  rd_out);

    always @(posedge clk or posedge res) begin
        if (res) begin
            RegWrite_out  <= 1'b0;
            MemtoReg_out  <= 1'b0;
            MemRead_out   <= 1'b0;
            MemWrite_out  <= 1'b0;
            Branch_out    <= 1'b0;
            pc_out        <= 32'b0;
            func3_out     <= 3'b0;
            zero_out      <= 1'b0;
            alu_out       <= 32'b0;
            reg2_data_out <= 32'b0;
            rd_out        <= 5'b0;
        end
        else if (write) begin
            RegWrite_out  <= RegWrite_in;
            MemtoReg_out  <= MemtoReg_in;
            MemRead_out   <= MemRead_in;
            MemWrite_out  <= MemWrite_in;
            Branch_out    <= Branch_in;
            pc_out        <= pc_in;
            func3_out     <= func3_in;
            zero_out      <= zero_in;
            alu_out       <= ALU_in;
            reg2_data_out <= reg2_data_in;
            rd_out        <= rd_in;
        end
    end

endmodule
