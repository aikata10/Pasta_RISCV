`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2023 11:25:53 AM
// Design Name: 
// Module Name: mod_mul_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define bitlen 17
`define q 65537
`define pasta_s 32

//pipeline stage 2
module mod_mul_wrapper(
    input clk,
    input [`bitlen*`pasta_s-1:0] in_modmul1,in_modmul2,
    output [`bitlen*`pasta_s-1:0] out_modmul
    );

 genvar i;


 generate 
    for (i = 0; i < `pasta_s; i = i + 1) begin: modadd_gen
            modmul mm (.clk(clk),
                    .in1(in_modmul1[`bitlen*(i+1)-1:`bitlen*i]),
                    .in2(in_modmul2[`bitlen*(i+1)-1:`bitlen*i]),
                    .out(out_modmul[`bitlen*(i+1)-1:`bitlen*i])
                    );
    end
 endgenerate
 

endmodule



module modmul(
 input clk,
 input [`bitlen-1:0] in1,in2,
 output [`bitlen-1:0] out
 );
 
 reg [2*`bitlen-1:0] temp1;
 reg [`bitlen:0] temp2;

 always @(posedge clk) begin
     temp1 <= in1*in2;
     temp2  <= temp1[`bitlen-1:0] - {temp1[2*`bitlen-1:`bitlen],1'b0};
 end
wire [`bitlen:0] temp3 =temp2+`q;
wire [`bitlen:0] temp4 =temp2-`q;
assign out = !temp4[`bitlen] ? temp4[`bitlen-1:0] : !temp2[`bitlen] ? temp2[`bitlen-1:0] : temp3[`bitlen-1:0]; 
endmodule
