`timescale 1ns / 1ps;

module IF(input clk, reset,
          input PCSrc, PC_write,
          input [31:0] PC_Branch,
          output [31:0] PC_IF, INSTRUCTION_IF);

    wire [31:0] pc_mux;
    wire [31:0] pc_if_4;
    
    adder pc_adder(PC_IF, 32'd4, pc_if_4);
    mux2_1 pc_selection_mux(pc_if_4, PC_Branch, PCSrc, pc_mux);
    PC pc(clk, reset, PC_write, pc_mux, PC_IF);
    // PC_IF << 2 sa iei adresa liniei din memorie
    instruction_memory im(PC_IF[11:2], INSTRUCTION_IF);
endmodule
 