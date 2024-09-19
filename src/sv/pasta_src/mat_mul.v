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




`define log_pasta_s 5 //log of pasta_s -- this is also the number of pipeline stages for add-tree
`define pipeline_stages_mm `log_pasta_s+4

module mat_mul(
    input clk,rst_mm,
    input [`bitlen*`pasta_s-1:0] vec_in,in_mm, modmul_out,//add_out,
    output [`bitlen*`pasta_s-1:0] modmul_in1_mm, modmul_in2_mm, //add_in1, add_in2,
    output reg [`bitlen*`pasta_s-1:0] out_mm,
    output done_mm
 );
    
 wire  [`bitlen*`pasta_s-1:0] vec_out;
 wire [`bitlen-1:0] sum_out;
 reg [5:0] ctr;
    
    
 //--------------------------Building block for generating the matrix for multiplication------------------//
   
 mat_gen matrix_gen(.clk(clk),
                    .vec_in(vec_in),//.prev_in(add_out),
                    //.add_in1(add_in1),.add_in2(add_in2),
                    .ctr(ctr),
                    .vec_out(vec_out));
 //-------------------------------------------------------------------------------------------------------//

 assign modmul_in1_mm=vec_out;
 assign modmul_in2_mm=in_mm;
 
 always @(posedge clk) begin
    if(rst_mm)
        ctr<=0;
    else 
        ctr<=ctr+1;
 end

wire start = ((ctr-`pipeline_stages_mm)>=0) ;
 // ---------------------------------------------- assigning the ouput value -----------------------------------------------------//
 genvar i;
 generate 
    for (i = 0; i < `pasta_s; i = i + 1) begin: add_mul_gen
        always @(posedge clk)
                out_mm[`bitlen*(i+1)-1:i*`bitlen] <= (start && (i==(`pasta_s-ctr+`pipeline_stages_mm))) ? sum_out : out_mm[`bitlen*(i+1)-1:i*`bitlen];
    end
 endgenerate
 //------------------------------------------------------------------------------------------------------------------------------//



 //------------This building block adds a row after matrix multiplication------------------//
 add_tree at(.clk(clk),.in_val(modmul_out),.out_val(sum_out));
 //---------------------------------------------------------------------------------------//

 assign done_mm = (ctr==(`pipeline_stages_mm+`pasta_s+1));


endmodule




// Binary tree like pipelined addition unit
module add_tree(
    input clk,
    input [`bitlen*`pasta_s-1:0] in_val,
    output [`bitlen-1:0] out_val
 );

 wire [`bitlen*`pasta_s-1:0] temp_in_val [`log_pasta_s:0];
 wire [`bitlen*`pasta_s-1:0] temp_out_val [`log_pasta_s-1:0];
 
 genvar l,i,j;
 
 generate
        for (l=0; l<`log_pasta_s ;l=l+1) begin: assign_unit 
                assign temp_in_val[l+1] = temp_out_val[l];
        end
    endgenerate 
 assign temp_in_val[0] = in_val;  

 generate 
    for (j = 0; j < `log_pasta_s; j = j + 1) begin: add_log_s_gen
        for (i = 0; i < `pasta_s; i = i + {1<<(j+1)}) begin: add_pasta_s_gen
                modadd ma(.clk(clk),
                          .in1(temp_in_val[j][`bitlen*(i+1)-1:i*`bitlen]),
                          .in2(temp_in_val[j][`bitlen*(i+(1<<(j))+1)-1:(i+(1<<(j)))*`bitlen]),
                          .out(temp_out_val[j][`bitlen*(i+1)-1:i*`bitlen])
                          );
        end
    end
 endgenerate

 assign out_val=temp_in_val[`log_pasta_s][`bitlen-1:0];



endmodule
