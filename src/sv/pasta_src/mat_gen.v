`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/27/2023 09:37:54 PM
// Design Name: 
// Module Name: mat_mul
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
`define rounds 4
`define rounds_s 3


module mat_gen(
    input clk,
    input [`bitlen*`pasta_s-1:0] vec_in,//prev_in,
    input [5:0] ctr,
    output reg [`bitlen*`pasta_s-1:0] vec_out//,
    //output [`bitlen*`pasta_s-1:0] add_in1,add_in2
    );


 
 wire [`bitlen*`pasta_s-1:0]mul_out, temp_in,add_in;


 
 always @(posedge clk) begin
    if(ctr<=1)
        vec_out<=vec_in;
    else
        vec_out<=mul_out;
 end
 

 assign add_in={{`bitlen{1'b0}},vec_out[`bitlen*(`pasta_s)-1:`bitlen]};
 assign temp_in = {`pasta_s{vec_out[`bitlen-1:0]}};
 
 mod_mul_and_add_wrapper modmuladd_wrap(.clk(clk),.in_modmul1(vec_in),.in_modmul2(temp_in),.in_modmul3(add_in),.out_modmul(mul_out)); 
 //-----------------------------------------------------------------------------------------------------------------//
 
 

endmodule



//pipeline stage 1
module mod_mul_and_add_wrapper(
    input clk,
    input [`bitlen*`pasta_s-1:0] in_modmul1,in_modmul2,in_modmul3,
    output [`bitlen*`pasta_s-1:0] out_modmul
    );

 genvar i;


 generate 
    for (i = 0; i < `pasta_s; i = i + 1) begin: modadd_gen
            modmuladd mma (.clk(clk),
                    .in1(in_modmul1[`bitlen*(i+1)-1:`bitlen*i]),
                    .in2(in_modmul2[`bitlen*(i+1)-1:`bitlen*i]),
                    .in3(in_modmul3[`bitlen*(i+1)-1:`bitlen*i]),
                    .out(out_modmul[`bitlen*(i+1)-1:`bitlen*i])
                    );
    end
 endgenerate
 

endmodule



module modmuladd(
 input clk,
 input [`bitlen-1:0] in1,in2,in3,
 output [`bitlen-1:0] out
 );
 
 wire [2*`bitlen-1:0] temp1;
 wire [`bitlen:0] temp2;

 assign temp1 = in1*in2;
 assign temp2 = temp1[`bitlen-1:0] - {temp1[2*`bitlen-1:`bitlen],1'b0};

wire [`bitlen:0] temp3 =temp2+`q;
wire [`bitlen:0] temp4 =temp2-`q;
wire [`bitlen-1:0] temp5 = !temp4[`bitlen] ? temp4 : !temp2[`bitlen] ? temp2 : temp3;
wire [`bitlen:0] temp6 = temp5+in3; 
wire [`bitlen:0] temp7 =temp6+`q;
wire [`bitlen:0] temp8 =temp6-`q;

assign out = !temp8[`bitlen] ? temp8[`bitlen-1:0] : !temp6[`bitlen] ? temp6[`bitlen-1:0] : temp7[`bitlen-1:0]; 

endmodule

