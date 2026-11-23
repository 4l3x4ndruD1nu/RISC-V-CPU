`timescale 1ns / 1ps

// Memoria de date: 4KB = 1024 cuvinte x 32 biti.
// Scriere sincrona (pe frontul pozitiv), citire asincrona.
module data_memory(input clk,
                   input mem_read,           //semnal de activare a citirii din memorie
                   input mem_write,          //semnal de activare a scrierii in memorie
                   input [31:0] address,     //adresa de scriere/citire
                   input [31:0] write_data,  //valoarea scrisa in memorie
                   output reg [31:0] read_data //valoarea citita din memorie
                   );

    reg [31:0] DataMemory [0:1023];
    wire [9:0] address_small;   // adresa de octet -> indexul cuvantului (ca la memoria de instructiuni)
    integer i;

    assign address_small = address[11:2];

    initial begin
        for (i = 0; i < 1024; i = i + 1)
            DataMemory[i] = 32'b0;
    end

    // scriere sincrona
    always @(posedge clk) begin
        if (mem_write)
            DataMemory[address_small] <= write_data;
    end

    // citire asincrona, doar cand mem_read = 1 (lw).
    // Cand mem_read = 0, read_data isi pastreaza ultima valoare citita (latch). Asa arata si
    // forma de unda din cerinta: DATA_MEMORY_MEM e X pana la primul lw, apoi ramane 3.
    // (Daca vrei logica pur combinationala: adauga "else read_data = 32'b0;")
    always @(*) begin
        if (mem_read)
            read_data = DataMemory[address_small];
    end

endmodule
