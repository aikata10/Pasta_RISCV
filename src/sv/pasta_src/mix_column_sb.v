`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2023 10:42:04 AM
// Design Name: 
// Module Name: mix_column_sb
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

`define init 0
`define state_mc 1
`define state_sb 2
`define end_state 3

`define pipe_mc 5
`define pipe_sb 4

`define bitlen 17
`define q 65537
`define pasta_s 32


// sb_mode 0 (no s-box), 2 (Cube s-box), otherwise general s-box
module mix_column_sb(
    input clk, rst_mc_sb,
    input [1:0] sb_mode,
    input [`bitlen*`pasta_s-1:0] in_mc_l,in_mc_r,modadd_out,modmul_out,
    output [`bitlen*`pasta_s-1:0] modadd_in1,modadd_in2,modmul_in1,modmul_in2,
    output reg [`bitlen*`pasta_s-1:0] out_sb_l, out_sb_r,
    output done_mc_sb
    );


 reg [1:0] state, nextstate;
 wire done_mc, done_sb1,done_sb2;
 reg [2:0] flag_mc;
 reg [3:0] flag_sb;
 wire [`bitlen*`pasta_s-1:0] temp_add,temp_modmul;
 reg  [`bitlen*`pasta_s-1:0] reg_temp_add;
 
 //-----------------------------// 
 //----State control signals----//   
 //-----------------------------// 
 always @(posedge clk) begin
    state<=nextstate;
 end 
//-----------------------------//   


 //-----------------------------// 
 //----Flag control signals----//   
 //-----------------------------// 
 always @(posedge clk) begin
    if(rst_mc_sb | done_mc)
        flag_mc<=0;
    else if((state==`state_mc))
        flag_mc<=flag_mc+1;
    else
        flag_mc<=flag_mc;
 end 
  always @(posedge clk) begin
    if(rst_mc_sb | done_sb2)
        flag_sb<=0;
    else if((state==`state_sb))
        flag_sb<=flag_sb+1;
    else
        flag_sb<=flag_sb;
 end 
//-----------------------------//   




 //-----------------------------// 
 //---------Mix Column----------//   
 //-----------------------------// 
 always @(posedge clk)begin
        reg_temp_add <= temp_add;
 end
 assign modadd_in1 = (state==`state_mc) ? ((flag_mc==0) ? out_sb_l : temp_add) : {{`bitlen{1'b0}},temp_modmul[`bitlen*(`pasta_s)-1:`bitlen]};
 assign modadd_in2 = (state==`state_mc) ? ((flag_mc==0) ? out_sb_r : (flag_mc==2) ? out_sb_l : out_sb_r) : ((flag_sb<`pipe_sb) ? out_sb_l : out_sb_r);

 assign temp_add= flag_mc==(`pipe_mc-2'd3) ? modadd_out : reg_temp_add;
 

 //-----------------------------// 
 
  
  //-----------------------------// 
 //-------------S-BOX------------//   
 //------------------------------// 

 assign modmul_in1=(flag_sb<`pipe_sb) ? out_sb_l : out_sb_r;
 assign modmul_in2= ((flag_sb==0 || flag_sb==`pipe_sb) ? (flag_sb==0 ? out_sb_l : out_sb_r) : temp_modmul);
 
 assign temp_modmul = modmul_out;
 
 
 //-----------------------------// 



 //---------------------------------------------------// 
 //------------------Output assignment----------------//   
 //---------------------------------------------------// 
 always @(posedge clk) begin
    if(state==`init) begin
        out_sb_l<=in_mc_l;
        out_sb_r<=in_mc_r;
    end
    else if(state==`state_mc) begin
         if( flag_mc==(`pipe_mc-2'd1)) begin
             out_sb_l<=modadd_out;
             out_sb_r<=out_sb_r;
           end
         else if(flag_mc==(`pipe_mc)) begin
             out_sb_l<=out_sb_l;
             out_sb_r<=modadd_out;
         end
    end
    else if(state==`state_sb) begin
        if(sb_mode==2'd1 & done_sb1 & !done_sb2) begin
            out_sb_l<=modadd_out;
            out_sb_r<=out_sb_r;
           end
       else if(sb_mode==2'd1 & done_sb2 ) begin
            out_sb_l<=out_sb_l;
            out_sb_r<=modadd_out;
           end
        else if(sb_mode==2'd2 & done_sb1 & !done_sb2) begin
            out_sb_l<=modmul_out;
            out_sb_r<=out_sb_r;
        end
         else if(sb_mode==2'd2 & done_sb2) begin
            out_sb_l<=out_sb_l;
            out_sb_r<=modmul_out;
        end
    end
    else begin
        out_sb_l<=out_sb_l;
        out_sb_r<=out_sb_r;
    end
 end
//---------------------------------------------------// 
 
 

 //----------------------------------------------------------------------------------------------//
 //------------------------------------Permutation control signals-------------------------------//
 //----------------------------------------------------------------------------------------------//  



 assign done_mc= (flag_mc==`pipe_mc);
 assign done_sb1 =  sb_mode==2'd2 ? (flag_sb==(`pipe_sb+1)) : (flag_sb==`pipe_sb);
 assign done_sb2 = sb_mode==2'd2 ? (flag_sb==(`pipe_sb*2+2)) : (flag_sb==(`pipe_sb*2+1));
 
 

 
 //Permutation controlpath 
 always @(*) begin
    if(rst_mc_sb)
        nextstate<=`init;
    else case(state) 
    `init     : nextstate <= `state_mc;
    `state_mc : nextstate <= done_mc     ? `state_sb  : `state_mc;
    `state_sb : nextstate <= done_sb2    ? `end_state : `state_sb;
    `end_state: nextstate <= `end_state;
    default: nextstate<=`init;
    endcase
 end
//----------------------------------------------------------------------------------------------//


assign done_mc_sb = (state==`end_state);

endmodule
