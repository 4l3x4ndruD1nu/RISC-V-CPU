`timescale 1ns / 1ps;

module IF(input clk, reset,
          input PCSrc, PC_write,
          input [31:0] PC_Branch,
          output [31:0] PC_IF, INSTRUCTION_IF);

    wire [31:0] instruction_address;
    wire [31:0] instruction;
    wire [31:0] pc_address;
    
    adder pc_adder(pc_address, 4, pc_address);
    mux2_1 pc_selection_mux(pc_address, PC_Branch, PCSrc, pc_address);
    PC pc(clk, reset, PC_write, PC_IF, instruction_address);      
    instruction_memoty im(instruction_address, instruction);
endmodule
 