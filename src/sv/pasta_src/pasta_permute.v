


`define init 0
`define matmul_l 1
`define temp_matmul_l 6
`define matmul_r 2
`define temp_matmul_r 7
`define rc_l 3
`define temp_rc_l 8
`define rc_r 4
`define temp_rc_r 9
`define mc_sb 5
`define temp_mc_sb 10
`define end_state_pp 11

`define bitlen 17
`define q 65537
`define pasta_s 32
`define rounds 4
`define rounds_s 3


module pasta_permute(
    input clk,rst,
    input [63:0] nonce,
    input [63:0] block_counter,
    input [`bitlen*`pasta_s-1:0] key_l, key_r,
    output reg [`bitlen*`pasta_s-1:0] out_l,out_r,
    output done
    );

//OUT for XOF function
wire [`bitlen*`pasta_s-1:0] vec1,vec2;
wire flag;
reg flag_reg;

//State variables
reg [3:0] state, nextstate;

//Round init variables
reg [2:0] rounds_ctr;
wire mat_gen, rounds_done;

//Matrix multiplication variables (mm -> matrix multiplication)
wire rst_mm,done_mm;
wire [`bitlen*`pasta_s-1:0] in_mm, out_mm,modmul_in1_mm,modmul_in2_mm;//modadd_in1_mm,modadd_in2_mm,

//Round Constant variables
wire rst_rc,done_rc;
wire [`bitlen*`pasta_s-1:0] in_rc, out_rc, modadd_in1_rc, modadd_in2_rc;

//Mix Column and S-box variables
wire rst_mc_sb,done_mc_sb;
wire [`bitlen*`pasta_s-1:0] in_mc_l, in_mc_r, out_sb_l, out_sb_r, modadd_in1_mc_sb, modadd_in2_mc_sb, modmul_in1_mc_sb, modmul_in2_mc_sb;
wire [1:0] sb_mode;

//Comman vars
wire [`bitlen*`pasta_s-1:0] vec_in;
reg [`bitlen*`pasta_s-1:0] in_modmul1,in_modmul2,in_modadd1,in_modadd2;
wire [`bitlen*`pasta_s-1:0] out_modmul,out_modadd;


 assign vec_in = flag==0 ? vec2 : vec1;




// -------------------------------------------------------------------------------------------------------------//
// XOF function taking the input nonce and block counter to generate matric initiation vector and round constants
// -------------------------------------------------------------------------------------------------------------//
 xof_shake128 xof(
    .clk(clk),
    .rst(rst),
    .nonce(nonce),
    .rounds_done(rounds_done),
    .block_counter(block_counter),
    .vec1(vec1),
    .vec2(vec2),
    .flag(flag)
 );
// -------------------------------------------------------------------------------------------------------------//

 
 
 
 //--------------------------------------------------------------------------------------------------------//
 //-------------------------Matrix Multiplication for both L and R states----------------------------------//
 //--------------------------------------------------------------------------------------------------------//
 reg reg_done_mm;
 assign rst_mm = rst || !((state==`matmul_l)||(state==`matmul_r)) ;
 assign in_mm  = state==`matmul_l ? out_l : out_r; 
 mat_mul m_mul(.clk(clk),.rst_mm(rst_mm),
               .vec_in(vec_in),.in_mm(in_mm),
               .modmul_in1_mm(modmul_in1_mm), .modmul_in2_mm(modmul_in2_mm), .modmul_out(out_modmul),
               .out_mm(out_mm),
               .done_mm(done_mm));
               

 //-------------------------------------------------------------------------------------------------------//
  
 
 
 
 //-------------------------------------------------------------------------------------------------------//
 //-----------------------Round constant addition for both L and R states---------------------------------//
 //-------------------------------------------------------------------------------------------------------//
 assign rst_rc = rst || !((state==`rc_l)||(state==`rc_r)) ;
 assign in_rc  = state==`rc_l ? out_l : out_r;
 round_constant rc_add(.clk(clk),.rst_rc(rst_rc),
                       .vec_in(vec_in),.in_rc(in_rc),
                       .modadd_in1(modadd_in1_rc),.modadd_in2(modadd_in2_rc),.modadd_out(out_modadd),
                       .out_rc(out_rc),
                       .done_rc(done_rc)); 
  //-----------------------------------------------------------------------------------------------------//
  
  
  
  
 //-------------------------------------------------------------------------------------------------------//
 //-------------------------------Mix column for R and L states after round constant----------------------//
 //-------------------------------------------------------------------------------------------------------//
 assign rst_mc_sb = rst || (state!=`mc_sb);
 assign in_mc_l  = out_l ;
 assign in_mc_r  = out_r; 
 assign sb_mode = rounds_ctr==3'd0 ? 2'd0 : rounds_ctr==3'd1 ? 2'd2 : 2'd1;
 mix_column_sb mc(.clk(clk),.rst_mc_sb(rst_mc_sb),.sb_mode(sb_mode),
                  .in_mc_l(in_mc_l),.in_mc_r(in_mc_r),
                  .modadd_in1(modadd_in1_mc_sb),.modadd_in2(modadd_in2_mc_sb),.modadd_out(out_modadd),
                  .modmul_in1(modmul_in1_mc_sb),.modmul_in2(modmul_in2_mc_sb),.modmul_out(out_modmul),
                  .out_sb_l(out_sb_l),
                  .out_sb_r(out_sb_r),.done_mc_sb(done_mc_sb)); 
//-------------------------------------------------------------------------------------------------------//
 
 
 
 
 //-----------------------------------------------------------------------------------------------------------------//
 // ------------------------- Here we declae the common mod mul and add unit used by different blocks---------------//
 //-----------------------------------------------------------------------------------------------------------------//
  always @(posedge clk) begin
    in_modmul1 <= !rst_mm ? modmul_in1_mm : modmul_in1_mc_sb;
    in_modmul2 <= !rst_mm ? modmul_in2_mm : modmul_in2_mc_sb;
 end
 mod_mul_wrapper modmul_wrap(.clk(clk),.in_modmul1(in_modmul1),.in_modmul2(in_modmul2),.out_modmul(out_modmul)); 
 
 //Common MODADD unit
 always @(posedge clk) begin
    in_modadd1 <= !rst_rc ? modadd_in1_rc : modadd_in1_mc_sb;
    in_modadd2 <= !rst_rc ? modadd_in2_rc : modadd_in2_mc_sb;
 end
 mod_add_wrapper modadd_wrap(.clk(clk),.in_modadd1(in_modadd1),.in_modadd2(in_modadd2),.out_modadd(out_modadd)); 
 //-----------------------------------------------------------------------------------------------------------------//
 
 
 
 
 //---------------------------------------------------// 
 //------------------Output assignment----------------//   
 //---------------------------------------------------// 
 always @(posedge clk) begin
    if(state==`init) begin
        out_l<=key_l;
        out_r<=key_r;
    end
    else if(state==`matmul_l & done_mm) begin
        out_l<=out_mm;
        out_r<=out_r;
    end
    else if(state==`matmul_r & done_mm) begin
        out_l<=out_l;
        out_r<=out_mm;
    end
    else if(state==`rc_l & done_rc) begin
        out_l<=out_rc;
        out_r<=out_r;
    end
    else if(state==`rc_r & done_rc) begin
        out_l<=out_l;
        out_r<=out_rc;
    end
    else if(state==`mc_sb & done_mc_sb) begin
        out_l<=out_sb_l;
        out_r<=out_sb_r;
    end
    else begin
        out_l<=out_l;
        out_r<=out_r;
    end
 end
//---------------------------------------------------// 
 
 
 
 //-----------------------------// 
 //----State control signals----//   
 //-----------------------------// 
 always @(posedge clk) begin
    if(rst)
        state<=`init;
    else
        state<=nextstate;
 end 
//-----------------------------//   
 
 
 
 
 //----------------------------------------------------------------------------------------------//
 //------------------------------------Permutation control signals-------------------------------//
 //----------------------------------------------------------------------------------------------//   
 always @(posedge clk) begin
    flag_reg<=flag;
    rounds_ctr<= rst ? (`rounds+1) : (state==`temp_rc_l && mat_gen) ? rounds_ctr-1 : rounds_ctr;
 end
 
 assign mat_gen= (flag_reg!=flag);
 assign rounds_done = (rounds_ctr==0);
 
 //Permutation controlpath 
 always @(*) begin
    case(state) 
    `init          : nextstate <= mat_gen      ? `matmul_l      : `init;
    `matmul_l      : nextstate <= done_mm      ? `temp_matmul_l : `matmul_l;
    `temp_matmul_l : nextstate <= mat_gen      ? `matmul_r      : `temp_matmul_l;
    `matmul_r      : nextstate <= done_mm      ? `temp_matmul_r : `matmul_r;
    `temp_matmul_r : nextstate <= mat_gen      ? `rc_l          : `temp_matmul_r;
    `rc_l          : nextstate <= done_rc      ? `temp_rc_l     : `rc_l;
    `temp_rc_l     : nextstate <= mat_gen      ? `rc_r          : `temp_rc_l;
    `rc_r          : nextstate <= done_rc      ? `mc_sb     : `rc_r;
    `mc_sb         : nextstate <= done_mc_sb   ? `temp_mc_sb    : `mc_sb;
    `temp_mc_sb    : nextstate <= rounds_done  ? `end_state_pp :  mat_gen ? `matmul_l : `temp_mc_sb;
    `end_state_pp: nextstate <= `end_state_pp;
    default: nextstate<=`init;
    endcase
 end
//----------------------------------------------------------------------------------------------//

assign done = (state==`end_state_pp);

endmodule