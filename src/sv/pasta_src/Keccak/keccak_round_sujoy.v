`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2020 09:16:37 PM
// Design Name: 
// Module Name: keccak_round_sujoy
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


module keccak_round_sujoy(lanes_in, round_constant, lanes_out);
input [64*5*5-1:0] lanes_in;
input [63:0] round_constant;
output [64*5*5-1:0] lanes_out;


// Start # ? step
wire [64*5-1:0] C;
assign C[64*1-1:64*0] = lanes_in[64*1-1:64*0]^lanes_in[64*2-1:64*1]^lanes_in[64*3-1:64*2]^lanes_in[64*4-1:64*3]^lanes_in[64*5-1:64*4];
assign C[64*2-1:64*1] = lanes_in[64*6-1:64*5]^lanes_in[64*7-1:64*6]^lanes_in[64*8-1:64*7]^lanes_in[64*9-1:64*8]^lanes_in[64*10-1:64*9];
assign C[64*3-1:64*2] = lanes_in[64*11-1:64*10]^lanes_in[64*12-1:64*11]^lanes_in[64*13-1:64*12]^lanes_in[64*14-1:64*13]^lanes_in[64*15-1:64*14];
assign C[64*4-1:64*3] = lanes_in[64*16-1:64*15]^lanes_in[64*17-1:64*16]^lanes_in[64*18-1:64*17]^lanes_in[64*19-1:64*18]^lanes_in[64*20-1:64*19];
assign C[64*5-1:64*4] = lanes_in[64*21-1:64*20]^lanes_in[64*22-1:64*21]^lanes_in[64*23-1:64*22]^lanes_in[64*24-1:64*23]^lanes_in[64*25-1:64*24];

wire [63:0] C_op[0:4];
assign {C_op[4], C_op[3], C_op[2], C_op[1], C_op[0]} = C;


wire [64*5-1:0] D;
assign D[64*1-1:64*0] = C[64*5-1:64*4] ^ {C[64*2-2:64*1],C[64*2-1]};
assign D[64*2-1:64*1] = C[64*1-1:64*0] ^ {C[64*3-2:64*2],C[64*3-1]};
assign D[64*3-1:64*2] = C[64*2-1:64*1] ^ {C[64*4-2:64*3],C[64*4-1]};
assign D[64*4-1:64*3] = C[64*3-1:64*2] ^ {C[64*5-2:64*4],C[64*5-1]};
assign D[64*5-1:64*4] = C[64*4-1:64*3] ^ {C[64*1-2:64*0],C[64*1-1]};

wire [63:0] D_op[0:4];
assign {D_op[4], D_op[3], D_op[2], D_op[1], D_op[0]} = D;

wire [64*5*5-1:0] lanes1, lanes2, lanes3, lanes4;
assign lanes1[64*1-1:64*0] = lanes_in[64*1-1:64*0]^D[64*1-1:64*0];
assign lanes1[64*2-1:64*1] = lanes_in[64*2-1:64*1]^D[64*1-1:64*0];
assign lanes1[64*3-1:64*2] = lanes_in[64*3-1:64*2]^D[64*1-1:64*0];
assign lanes1[64*4-1:64*3] = lanes_in[64*4-1:64*3]^D[64*1-1:64*0];
assign lanes1[64*5-1:64*4] = lanes_in[64*5-1:64*4]^D[64*1-1:64*0];

assign lanes1[64*6-1:64*5] = lanes_in[64*6-1:64*5]^D[64*2-1:64*1];
assign lanes1[64*7-1:64*6] = lanes_in[64*7-1:64*6]^D[64*2-1:64*1];
assign lanes1[64*8-1:64*7] = lanes_in[64*8-1:64*7]^D[64*2-1:64*1];
assign lanes1[64*9-1:64*8] = lanes_in[64*9-1:64*8]^D[64*2-1:64*1];
assign lanes1[64*10-1:64*9] = lanes_in[64*10-1:64*9]^D[64*2-1:64*1];

assign lanes1[64*11-1:64*10] = lanes_in[64*11-1:64*10]^D[64*3-1:64*2];
assign lanes1[64*12-1:64*11] = lanes_in[64*12-1:64*11]^D[64*3-1:64*2];
assign lanes1[64*13-1:64*12] = lanes_in[64*13-1:64*12]^D[64*3-1:64*2];
assign lanes1[64*14-1:64*13] = lanes_in[64*14-1:64*13]^D[64*3-1:64*2];
assign lanes1[64*15-1:64*14] = lanes_in[64*15-1:64*14]^D[64*3-1:64*2];

assign lanes1[64*16-1:64*15] = lanes_in[64*16-1:64*15]^D[64*4-1:64*3];
assign lanes1[64*17-1:64*16] = lanes_in[64*17-1:64*16]^D[64*4-1:64*3];
assign lanes1[64*18-1:64*17] = lanes_in[64*18-1:64*17]^D[64*4-1:64*3];
assign lanes1[64*19-1:64*18] = lanes_in[64*19-1:64*18]^D[64*4-1:64*3];
assign lanes1[64*20-1:64*19] = lanes_in[64*20-1:64*19]^D[64*4-1:64*3];

assign lanes1[64*21-1:64*20] = lanes_in[64*21-1:64*20]^D[64*5-1:64*4];
assign lanes1[64*22-1:64*21] = lanes_in[64*22-1:64*21]^D[64*5-1:64*4];
assign lanes1[64*23-1:64*22] = lanes_in[64*23-1:64*22]^D[64*5-1:64*4];
assign lanes1[64*24-1:64*23] = lanes_in[64*24-1:64*23]^D[64*5-1:64*4];
assign lanes1[64*25-1:64*24] = lanes_in[64*25-1:64*24]^D[64*5-1:64*4];

// End # ? step

wire [63:0] lanes1_op[0:4][0:4];
assign 	{lanes1_op[4][4],lanes1_op[4][3],lanes1_op[4][2],lanes1_op[4][1],lanes1_op[4][0],
         lanes1_op[3][4],lanes1_op[3][3],lanes1_op[3][2],lanes1_op[3][1],lanes1_op[3][0],
         lanes1_op[2][4],lanes1_op[2][3],lanes1_op[2][2],lanes1_op[2][1],lanes1_op[2][0],
         lanes1_op[1][4],lanes1_op[1][3],lanes1_op[1][2],lanes1_op[1][1],lanes1_op[1][0],
         lanes1_op[0][4],lanes1_op[0][3],lanes1_op[0][2],lanes1_op[0][1],lanes1_op[0][0]} = lanes1;

// # ? and ? steps
////////////////////////////////// Start: Permutation Step  /////////////////////////
wire [63:0] current_0_2, current_2_1, current_1_2, current_2_3, current_3_3, current_3_0, current_0_1, current_1_3, current_3_1, current_1_4, current_4_4, current_4_0, current_0_3, current_3_4, current_4_3, current_3_2, current_2_2, current_2_0, current_0_4, current_4_2, current_2_4, current_4_1, current_1_1, current_1_0;

assign lanes2[63:0] = lanes1[63:0];
assign current_0_2 =lanes1[1*5*64+1*64-1 : 1*5*64+0*64];
assign lanes2[0*5*64+3*64-1: 0*5*64+2*64] = {current_0_2[62 :0], current_0_2[63: 63]};
assign current_2_1 =lanes1[0*5*64+3*64-1 : 0*5*64+2*64];
assign lanes2[2*5*64+2*64-1: 2*5*64+1*64] = {current_2_1[60 :0], current_2_1[63: 61]};
assign current_1_2 =lanes1[2*5*64+2*64-1 : 2*5*64+1*64];
assign lanes2[1*5*64+3*64-1: 1*5*64+2*64] = {current_1_2[57 :0], current_1_2[63: 58]};
assign current_2_3 =lanes1[1*5*64+3*64-1 : 1*5*64+2*64];
assign lanes2[2*5*64+4*64-1: 2*5*64+3*64] = {current_2_3[53 :0], current_2_3[63: 54]};
assign current_3_3 =lanes1[2*5*64+4*64-1 : 2*5*64+3*64];
assign lanes2[3*5*64+4*64-1: 3*5*64+3*64] = {current_3_3[48 :0], current_3_3[63: 49]};
assign current_3_0 =lanes1[3*5*64+4*64-1 : 3*5*64+3*64];
assign lanes2[3*5*64+1*64-1: 3*5*64+0*64] = {current_3_0[42 :0], current_3_0[63: 43]};
assign current_0_1 =lanes1[3*5*64+1*64-1 : 3*5*64+0*64];
assign lanes2[0*5*64+2*64-1: 0*5*64+1*64] = {current_0_1[35 :0], current_0_1[63: 36]};
assign current_1_3 =lanes1[0*5*64+2*64-1 : 0*5*64+1*64];
assign lanes2[1*5*64+4*64-1: 1*5*64+3*64] = {current_1_3[27 :0], current_1_3[63: 28]};
assign current_3_1 =lanes1[1*5*64+4*64-1 : 1*5*64+3*64];
assign lanes2[3*5*64+2*64-1: 3*5*64+1*64] = {current_3_1[18 :0], current_3_1[63: 19]};
assign current_1_4 =lanes1[3*5*64+2*64-1 : 3*5*64+1*64];
assign lanes2[1*5*64+5*64-1: 1*5*64+4*64] = {current_1_4[8 :0], current_1_4[63: 9]};
assign current_4_4 =lanes1[1*5*64+5*64-1 : 1*5*64+4*64];
assign lanes2[4*5*64+5*64-1: 4*5*64+4*64] = {current_4_4[61 :0], current_4_4[63: 62]};
assign current_4_0 =lanes1[4*5*64+5*64-1 : 4*5*64+4*64];
assign lanes2[4*5*64+1*64-1: 4*5*64+0*64] = {current_4_0[49 :0], current_4_0[63: 50]};
assign current_0_3 =lanes1[4*5*64+1*64-1 : 4*5*64+0*64];
assign lanes2[0*5*64+4*64-1: 0*5*64+3*64] = {current_0_3[36 :0], current_0_3[63: 37]};
assign current_3_4 =lanes1[0*5*64+4*64-1 : 0*5*64+3*64];
assign lanes2[3*5*64+5*64-1: 3*5*64+4*64] = {current_3_4[22 :0], current_3_4[63: 23]};
assign current_4_3 =lanes1[3*5*64+5*64-1 : 3*5*64+4*64];
assign lanes2[4*5*64+4*64-1: 4*5*64+3*64] = {current_4_3[7 :0], current_4_3[63: 8]};
assign current_3_2 =lanes1[4*5*64+4*64-1 : 4*5*64+3*64];
assign lanes2[3*5*64+3*64-1: 3*5*64+2*64] = {current_3_2[55 :0], current_3_2[63: 56]};
assign current_2_2 =lanes1[3*5*64+3*64-1 : 3*5*64+2*64];
assign lanes2[2*5*64+3*64-1: 2*5*64+2*64] = {current_2_2[38 :0], current_2_2[63: 39]};
assign current_2_0 =lanes1[2*5*64+3*64-1 : 2*5*64+2*64];
assign lanes2[2*5*64+1*64-1: 2*5*64+0*64] = {current_2_0[20 :0], current_2_0[63: 21]};
assign current_0_4 =lanes1[2*5*64+1*64-1 : 2*5*64+0*64];
assign lanes2[0*5*64+5*64-1: 0*5*64+4*64] = {current_0_4[1 :0], current_0_4[63: 2]};
assign current_4_2 =lanes1[0*5*64+5*64-1 : 0*5*64+4*64];
assign lanes2[4*5*64+3*64-1: 4*5*64+2*64] = {current_4_2[45 :0], current_4_2[63: 46]};
assign current_2_4 =lanes1[4*5*64+3*64-1 : 4*5*64+2*64];
assign lanes2[2*5*64+5*64-1: 2*5*64+4*64] = {current_2_4[24 :0], current_2_4[63: 25]};
assign current_4_1 =lanes1[2*5*64+5*64-1 : 2*5*64+4*64];
assign lanes2[4*5*64+2*64-1: 4*5*64+1*64] = {current_4_1[2 :0], current_4_1[63: 3]};
assign current_1_1 =lanes1[4*5*64+2*64-1 : 4*5*64+1*64];
assign lanes2[1*5*64+2*64-1: 1*5*64+1*64] = {current_1_1[43 :0], current_1_1[63: 44]};
assign current_1_0 =lanes1[1*5*64+2*64-1 : 1*5*64+1*64];
assign lanes2[1*5*64+1*64-1: 1*5*64+0*64] = {current_1_0[19 :0], current_1_0[63: 20]};

////////////////////////////////// End: Permutation Step  /////////////////////////
wire [63:0] lanes2_op[0:4][0:4];
assign 	{lanes2_op[4][4],lanes2_op[4][3],lanes2_op[4][2],lanes2_op[4][1],lanes2_op[4][0],
         lanes2_op[3][4],lanes2_op[3][3],lanes2_op[3][2],lanes2_op[3][1],lanes2_op[3][0],
         lanes2_op[2][4],lanes2_op[2][3],lanes2_op[2][2],lanes2_op[2][1],lanes2_op[2][0],
         lanes2_op[1][4],lanes2_op[1][3],lanes2_op[1][2],lanes2_op[1][1],lanes2_op[1][0],
         lanes2_op[0][4],lanes2_op[0][3],lanes2_op[0][2],lanes2_op[0][1],lanes2_op[0][0]} = lanes2;


// Start # ? step
wire [64*5-1:0] T0, T1, T2, T3, T4;
assign T0 = {lanes2[64*21-1:64*20], lanes2[64*16-1:64*15], lanes2[64*11-1:64*10], lanes2[64*6-1:64*5], lanes2[64*1-1:64*0]};
assign lanes3[0*5*64+0*64+63: 0*5*64+0*64]=T0[1*64-1: 0*64] ^ ((~T0[2*64-1: 1*64]) & T0[3*64-1: 2*64]);
assign lanes3[1*5*64+0*64+63: 1*5*64+0*64]=T0[2*64-1: 1*64] ^ ((~T0[3*64-1: 2*64]) & T0[4*64-1: 3*64]);
assign lanes3[2*5*64+0*64+63: 2*5*64+0*64]=T0[3*64-1: 2*64] ^ ((~T0[4*64-1: 3*64]) & T0[5*64-1: 4*64]);
assign lanes3[3*5*64+0*64+63: 3*5*64+0*64]=T0[4*64-1: 3*64] ^ ((~T0[5*64-1: 4*64]) & T0[1*64-1: 0*64]);
assign lanes3[4*5*64+0*64+63: 4*5*64+0*64]=T0[5*64-1: 4*64] ^ ((~T0[1*64-1: 0*64]) & T0[2*64-1: 1*64]);

assign T1 = {lanes2[64*21-1+64*1:64*20+64*1], lanes2[64*16-1+64*1:64*15+64*1], lanes2[64*11-1+64*1:64*10+64*1], lanes2[64*6-1+64*1:64*5+64*1], lanes2[64*1-1+64*1:64*0+64*1]};
assign lanes3[0*5*64+1*64+63: 0*5*64+1*64]=T1[1*64-1: 0*64] ^ ((~T1[2*64-1: 1*64]) & T1[3*64-1: 2*64]);
assign lanes3[1*5*64+1*64+63: 1*5*64+1*64]=T1[2*64-1: 1*64] ^ ((~T1[3*64-1: 2*64]) & T1[4*64-1: 3*64]);
assign lanes3[2*5*64+1*64+63: 2*5*64+1*64]=T1[3*64-1: 2*64] ^ ((~T1[4*64-1: 3*64]) & T1[5*64-1: 4*64]);
assign lanes3[3*5*64+1*64+63: 3*5*64+1*64]=T1[4*64-1: 3*64] ^ ((~T1[5*64-1: 4*64]) & T1[1*64-1: 0*64]);
assign lanes3[4*5*64+1*64+63: 4*5*64+1*64]=T1[5*64-1: 4*64] ^ ((~T1[1*64-1: 0*64]) & T1[2*64-1: 1*64]);

assign T2 = {lanes2[64*21-1+64*2:64*20+64*2], lanes2[64*16-1+64*2:64*15+64*2], lanes2[64*11-1+64*2:64*10+64*2], lanes2[64*6-1+64*2:64*5+64*2], lanes2[64*1-1+64*2:64*0+64*2]};
assign lanes3[0*5*64+2*64+63: 0*5*64+2*64]=T2[1*64-1: 0*64] ^ ((~T2[2*64-1: 1*64]) & T2[3*64-1: 2*64]);
assign lanes3[1*5*64+2*64+63: 1*5*64+2*64]=T2[2*64-1: 1*64] ^ ((~T2[3*64-1: 2*64]) & T2[4*64-1: 3*64]);
assign lanes3[2*5*64+2*64+63: 2*5*64+2*64]=T2[3*64-1: 2*64] ^ ((~T2[4*64-1: 3*64]) & T2[5*64-1: 4*64]);
assign lanes3[3*5*64+2*64+63: 3*5*64+2*64]=T2[4*64-1: 3*64] ^ ((~T2[5*64-1: 4*64]) & T2[1*64-1: 0*64]);
assign lanes3[4*5*64+2*64+63: 4*5*64+2*64]=T2[5*64-1: 4*64] ^ ((~T2[1*64-1: 0*64]) & T2[2*64-1: 1*64]);

assign T3 = {lanes2[64*21-1+64*3:64*20+64*3], lanes2[64*16-1+64*3:64*15+64*3], lanes2[64*11-1+64*3:64*10+64*3], lanes2[64*6-1+64*3:64*5+64*3], lanes2[64*1-1+64*3:64*0+64*3]};
assign lanes3[0*5*64+3*64+63: 0*5*64+3*64]=T3[1*64-1: 0*64] ^ ((~T3[2*64-1: 1*64]) & T3[3*64-1: 2*64]);
assign lanes3[1*5*64+3*64+63: 1*5*64+3*64]=T3[2*64-1: 1*64] ^ ((~T3[3*64-1: 2*64]) & T3[4*64-1: 3*64]);
assign lanes3[2*5*64+3*64+63: 2*5*64+3*64]=T3[3*64-1: 2*64] ^ ((~T3[4*64-1: 3*64]) & T3[5*64-1: 4*64]);
assign lanes3[3*5*64+3*64+63: 3*5*64+3*64]=T3[4*64-1: 3*64] ^ ((~T3[5*64-1: 4*64]) & T3[1*64-1: 0*64]);
assign lanes3[4*5*64+3*64+63: 4*5*64+3*64]=T3[5*64-1: 4*64] ^ ((~T3[1*64-1: 0*64]) & T3[2*64-1: 1*64]);

assign T4 = {lanes2[64*21-1+64*4:64*20+64*4], lanes2[64*16-1+64*4:64*15+64*4], lanes2[64*11-1+64*4:64*10+64*4], lanes2[64*6-1+64*4:64*5+64*4], lanes2[64*1-1+64*4:64*0+64*4]};
assign lanes3[0*5*64+4*64+63: 0*5*64+4*64]=T4[1*64-1: 0*64] ^ ((~T4[2*64-1: 1*64]) & T4[3*64-1: 2*64]);
assign lanes3[1*5*64+4*64+63: 1*5*64+4*64]=T4[2*64-1: 1*64] ^ ((~T4[3*64-1: 2*64]) & T4[4*64-1: 3*64]);
assign lanes3[2*5*64+4*64+63: 2*5*64+4*64]=T4[3*64-1: 2*64] ^ ((~T4[4*64-1: 3*64]) & T4[5*64-1: 4*64]);
assign lanes3[3*5*64+4*64+63: 3*5*64+4*64]=T4[4*64-1: 3*64] ^ ((~T4[5*64-1: 4*64]) & T4[1*64-1: 0*64]);
assign lanes3[4*5*64+4*64+63: 4*5*64+4*64]=T4[5*64-1: 4*64] ^ ((~T4[1*64-1: 0*64]) & T4[2*64-1: 1*64]);

// End # ? step

wire [63:0] lanes3_op[0:4][0:4];
assign 	{lanes3_op[4][4],lanes3_op[4][3],lanes3_op[4][2],lanes3_op[4][1],lanes3_op[4][0],
         lanes3_op[3][4],lanes3_op[3][3],lanes3_op[3][2],lanes3_op[3][1],lanes3_op[3][0],
         lanes3_op[2][4],lanes3_op[2][3],lanes3_op[2][2],lanes3_op[2][1],lanes3_op[2][0],
         lanes3_op[1][4],lanes3_op[1][3],lanes3_op[1][2],lanes3_op[1][1],lanes3_op[1][0],
         lanes3_op[0][4],lanes3_op[0][3],lanes3_op[0][2],lanes3_op[0][1],lanes3_op[0][0]} = lanes3;


assign lanes_out = {lanes3[25*64-1:64], lanes3[63:0]^round_constant};

endmodule
