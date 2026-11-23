`timescale 1ns / 1ps

module IF_ID_reg(input clk, res, write,
                 input [31:0] pc_in, instruction_in,
                 output reg [31:0] pc_out, instruction_out);

    always @(posedge clk or posedge res) begin
        if (res) begin
            pc_out          <= 32'b0;
            instruction_out <= 32'b0;
        end
        else if (write) begin              // IF_ID_write = 0 -> stall (Lucrarea 3)
            pc_out          <= pc_in;
            instruction_out <= instruction_in;
        end
    end

endmodule