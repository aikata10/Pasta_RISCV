`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2023 10:12:45 AM
// Design Name: 
// Module Name: round_constant
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

module round_constant(
    input clk,rst_rc,
    input [`bitlen*`pasta_s-1:0] vec_in,in_rc,modadd_out,
    output [`bitlen*`pasta_s-1:0] modadd_in1, modadd_in2, out_rc,
    output reg done_rc
    );

assign modadd_in1 = vec_in;
assign modadd_in2 = in_rc;
assign out_rc    = modadd_out;
reg temp_done;
 always @(posedge clk) begin
    temp_done<=(!rst_rc);
    done_rc<=temp_done;
 end
 
endmodule






