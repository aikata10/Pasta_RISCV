`timescale 1ns / 1ps

   
module byte_reverse(
    input [63:0] initial_value,
    output reg [63:0] final_value
);
reg [7:0] part0, part1, part2, part3, part4, part5, part6, part7;
always @(*) begin
    part0 = initial_value[7:0];
    part1 = initial_value[15:8];
    part2 = initial_value[23:16];
    part3 = initial_value[31:24];
    part4 = initial_value[39:32];
    part5 = initial_value[47:40];
    part6 = initial_value[55:48];
    part7 = initial_value[63:56];

    final_value = {part0, part1, part2, part3, part4, part5, part6, part7};
end

endmodule
