`timescale 1ns / 1ps

// Registrul de pipeline MEM/WB: control (WB) + valoarea citita din memorie + rezultatul ALU.
module MEM_WB_reg(input clk, res, write,
                  // control
                  input RegWrite_in, MemtoReg_in,                 // WB
                  // date
                  input [31:0] data_in,                           // DATA_MEMORY_MEM
                  input [31:0] alu_in,                            // ALU_OUT_MEM
                  input [4:0]  rd_in,                             // RD_MEM

                  output reg RegWrite_out, MemtoReg_out,
                  output reg [31:0] data_out,
                  output reg [31:0] alu_out,
                  output reg [4:0]  rd_out);

    always @(posedge clk or posedge res) begin
        if (res) begin
            RegWrite_out <= 1'b0;
            MemtoReg_out <= 1'b0;
            data_out     <= 32'b0;
            alu_out      <= 32'b0;
            rd_out       <= 5'b0;
        end
        else if (write) begin
            RegWrite_out <= RegWrite_in;
            MemtoReg_out <= MemtoReg_in;
            data_out     <= data_in;
            alu_out      <= alu_in;
            rd_out       <= rd_in;
        end
    end

endmodule
