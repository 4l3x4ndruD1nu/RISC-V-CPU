module PC(
    input clk,
    input res,
    input write,
    input [31:0] in,
    output reg [31:0] out);
   
    always @(posedge clk or posedge res) begin
        if (res)
            out <= 32'd0;
        else if (write) begin
            out=in;
            end
        end
endmodule