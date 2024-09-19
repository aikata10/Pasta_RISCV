`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/25/2023 10:17:25 PM
// Design Name: 
// Module Name: xof_shake128
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

module xof_shake128(
    input clk,rst,
    input [63:0] nonce,
    input rounds_done,
    input [63:0] block_counter,
    output reg [`bitlen*`pasta_s-1:0] vec1, vec2,
    output reg flag
    );

    wire [9:0] dummy_wa,read_address;
    wire dummy_done;
    wire we;
    reg [63:0] din_64bit;
    wire [63:0] dout_64bit;
    wire we_1,we_2;
    reg [5:0] ctr;
    
    wrapper_Keccak uut (
        .clk(clk), 
        .rst(rst), 
        .rounds_done(rounds_done),
        .mode_type(2'd2), 
        .inputByteLen(16'd16), 
        .read_address(read_address), 
        .din_64bit(din_64bit),
        .outputByteLen(16'd10880), 
        .dout_64bit(dout_64bit),
        .write_address(dummy_wa), 
        .we(we), 
        .done(dummy_done)
    );
    
  
  // Rejection sampling here
  wire [`bitlen-1:0] sampl_out =  dout_64bit[`bitlen-1:0];
  wire rej =   we & (sampl_out<`q);
  
  always @(posedge clk) begin
    case(read_address) 
           1'b0: din_64bit<=nonce;
           1'b1: din_64bit<=block_counter;
        default: din_64bit<=64'b0; 
    endcase
  end


 // Buffer storage controlpath here
  always @(posedge clk) begin
       if(rst || (ctr==6'd31 && rej))
            ctr<=0;
       else if(rej)
            ctr<=ctr+1;
        else
            ctr<=ctr;
  end
  
  always @(posedge clk) begin
       if(rst)
            flag<=0;
       else if(ctr==6'd31 && rej)
            flag<=flag+1;
       else
            flag<=flag;
  end
  
  assign we_1  = (flag==0);
  assign we_2  = (flag==1);

  
   // Buffer storage datapath here
  always @(posedge clk) begin
    if(rst) begin
                vec1<=0;vec2<=0;
    end else if(rej) begin
                 if(we_1) begin
                    vec1<={vec1[`bitlen*(`pasta_s-1)-1:0],sampl_out};   vec2<=vec2;
                end
                else if(we_2) begin
                    vec1<=vec1;    vec2<={vec2[`bitlen*(`pasta_s-1)-1:0],sampl_out};
                end
                else begin
                    vec1<=vec1;    vec2<=vec2;
                end           
        end       
  end



endmodule
