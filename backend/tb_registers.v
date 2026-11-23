`timescale 1ns / 1ps

module tb_registers;
    reg clk = 0, reg_write = 0;
    reg [4:0] read_reg1 = 0, read_reg2 = 0, write_reg = 0;
    reg [31:0] write_data = 0;
    wire [31:0] read_data1, read_data2;

    registers uut(.clk(clk), .reg_write(reg_write),
                  .read_reg1(read_reg1), .read_reg2(read_reg2),
                  .write_reg(write_reg), .write_data(write_data),
                  .read_data1(read_data1), .read_data2(read_data2));

    always #5 clk = ~clk;

    initial begin
        #2  read_reg1 = 5'd3;  read_reg2 = 5'd31;                            // citire asincrona: 3, 31
        #10 reg_write = 1; write_reg = 5'd3; write_data = 32'hDEADBEEF;  // scrie x3
        #10 reg_write = 1; write_reg = 5'd0; write_data = 32'hFFFFFFFF;  // x0 trebuie sa ramana 0
        #10 reg_write = 0; write_reg = 5'd5; write_data = 32'h12345678;  // reg_write=0 -> nu scrie
        #10 read_reg1 = 5'd0;  read_reg2 = 5'd5;                            // verifica x0 si x5
        #10 $finish;
    end
endmodule