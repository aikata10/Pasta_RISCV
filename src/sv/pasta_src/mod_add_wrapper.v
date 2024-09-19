`define bitlen 17
`define q 65537
`define pasta_s 32




//pipeline stage 1
module mod_add_wrapper(
    input clk,
    input  [`bitlen*`pasta_s-1:0] in_modadd1,in_modadd2,
    output [`bitlen*`pasta_s-1:0] out_modadd
    );

 genvar i;


 generate 
    for (i = 0; i < `pasta_s; i = i + 1) begin: modadd_gen
            modadd ma (.clk(clk),
                    .in1(in_modadd1[`bitlen*(i+1)-1:`bitlen*i]),
                    .in2(in_modadd2[`bitlen*(i+1)-1:`bitlen*i]),
                    .out(out_modadd[`bitlen*(i+1)-1:`bitlen*i])
                    );
    end
 endgenerate
 

endmodule





module modadd(
 input clk,
 input [`bitlen-1:0] in1,in2,
 output reg [`bitlen-1:0] out
 );
 
wire [`bitlen:0] temp = in1+in2;

    always @(posedge clk) begin
         out <= temp>=`q ? temp-`q : temp;
    end

endmodule
