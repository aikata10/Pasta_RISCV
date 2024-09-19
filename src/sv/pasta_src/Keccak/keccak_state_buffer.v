`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2020 07:03:08 PM
// Design Name: 
// Module Name: keccak_state_buffer
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


module keccak_state_buffer(clk, rst, din_64bit, din_wen, state_out, state_in, we_state_in,
                           state_output_sel, we_output_buffer, shift_output_buffer, dout_64bit);
input clk;
input rst; // Clears the state buffer when 1

input [63:0] din_64bit; // Data comes in 64 bit chunks
input din_wen;  // write enable signal for input data

output [25*64-1:0] state_out;
input [25*64-1:0] state_in; 
input we_state_in;

input [4:0] state_output_sel;
input we_output_buffer;             // When 1, keccak_state is written into the output_buffer
input shift_output_buffer;          // When 1, output_buffer is shifted by 64-bits every cycle. One word is output
output [63:0] dout_64bit;       // Data output happens in 64 bit chunks

reg [64*25-1:0] keccak_state;
reg [64*21-1:0] keccak_output_buffer;   // Note that at most 21 words are output. (shake128 outputs 21 64-bit words) 
reg [4:0] din_slot;
wire [63:0] dout_64bit_wire;
always @(posedge clk)
begin
    if(rst)
        din_slot <= 5'd0;
    else if(din_wen)
        din_slot <= din_slot + 1'b1;
    else 
        din_slot <= 5'd0;
end
               
always @(posedge clk)
begin
    if(rst)
        keccak_state <= 1600'b0;

    // For y = 0..4 with x = 0
    else if(din_wen==1'b1 && din_slot==5'd0)
        keccak_state[63+64*5*0+64*0:64*5*0+64*0] <= keccak_state[63+64*5*0+64*0:64*5*0+64*0] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd1)
        keccak_state[63+64*5*0+64*1:64*5*0+64*1] <= keccak_state[63+64*5*0+64*1:64*5*0+64*1] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd2)
        keccak_state[63+64*5*0+64*2:64*5*0+64*2] <= keccak_state[63+64*5*0+64*2:64*5*0+64*2] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd3)
        keccak_state[63+64*5*0+64*3:64*5*0+64*3] <= keccak_state[63+64*5*0+64*3:64*5*0+64*3] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd4)
        keccak_state[63+64*5*0+64*4:64*5*0+64*4] <= keccak_state[63+64*5*0+64*4:64*5*0+64*4] ^ din_64bit;

    // For y = 0..4 with x = 1
    else if(din_wen==1'b1 && din_slot==5'd5)
        keccak_state[63+64*5*1+64*0:64*5*1+64*0] <= keccak_state[63+64*5*1+64*0:64*5*1+64*0] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd6)
        keccak_state[63+64*5*1+64*1:64*5*1+64*1] <= keccak_state[63+64*5*1+64*1:64*5*1+64*1] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd7)
        keccak_state[63+64*5*1+64*2:64*5*1+64*2] <= keccak_state[63+64*5*1+64*2:64*5*1+64*2] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd8)
        keccak_state[63+64*5*1+64*3:64*5*1+64*3] <= keccak_state[63+64*5*1+64*3:64*5*1+64*3] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd9)
        keccak_state[63+64*5*1+64*4:64*5*1+64*4] <= keccak_state[63+64*5*1+64*4:64*5*1+64*4] ^ din_64bit;

    // For y = 0..4 with x = 2
    else if(din_wen==1'b1 && din_slot==5'd10)
        keccak_state[63+64*5*2+64*0:64*5*2+64*0] <= keccak_state[63+64*5*2+64*0:64*5*2+64*0] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd11)
        keccak_state[63+64*5*2+64*1:64*5*2+64*1] <= keccak_state[63+64*5*2+64*1:64*5*2+64*1] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd12)
        keccak_state[63+64*5*2+64*2:64*5*2+64*2] <= keccak_state[63+64*5*2+64*2:64*5*2+64*2] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd13)
        keccak_state[63+64*5*2+64*3:64*5*2+64*3] <= keccak_state[63+64*5*2+64*3:64*5*2+64*3] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd14)
        keccak_state[63+64*5*2+64*4:64*5*2+64*4] <= keccak_state[63+64*5*2+64*4:64*5*2+64*4] ^ din_64bit;

    // For y = 0..4 with x = 3
    else if(din_wen==1'b1 && din_slot==5'd15)
        keccak_state[63+64*5*3+64*0:64*5*3+64*0] <= keccak_state[63+64*5*3+64*0:64*5*3+64*0] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd16)
        keccak_state[63+64*5*3+64*1:64*5*3+64*1] <= keccak_state[63+64*5*3+64*1:64*5*3+64*1] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd17)
        keccak_state[63+64*5*3+64*2:64*5*3+64*2] <= keccak_state[63+64*5*3+64*2:64*5*3+64*2] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd18)
        keccak_state[63+64*5*3+64*3:64*5*3+64*3] <= keccak_state[63+64*5*3+64*3:64*5*3+64*3] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd19)
        keccak_state[63+64*5*3+64*4:64*5*3+64*4] <= keccak_state[63+64*5*3+64*4:64*5*3+64*4] ^ din_64bit;

    // For y = 0..4 with x = 4
    else if(din_wen==1'b1 && din_slot==5'd20)
        keccak_state[63+64*5*4+64*0:64*5*4+64*0] <= keccak_state[63+64*5*4+64*0:64*5*4+64*0] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd21)
        keccak_state[63+64*5*4+64*1:64*5*4+64*1] <= keccak_state[63+64*5*4+64*1:64*5*4+64*1] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd22)
        keccak_state[63+64*5*4+64*2:64*5*4+64*2] <= keccak_state[63+64*5*4+64*2:64*5*4+64*2] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd23)
        keccak_state[63+64*5*4+64*3:64*5*4+64*3] <= keccak_state[63+64*5*4+64*3:64*5*4+64*3] ^ din_64bit;
    else if(din_wen==1'b1 && din_slot==5'd24)
        keccak_state[63+64*5*4+64*4:64*5*4+64*4] <= keccak_state[63+64*5*4+64*4:64*5*4+64*4] ^ din_64bit;

    //////
    // Now input for state from Keccak Round
    else if(we_state_in)
        keccak_state <= state_in;
    else
        keccak_state <= keccak_state;                                                           
end

assign state_out = keccak_state;

// Update outpu buffer
always @(posedge clk)
begin
    if(we_output_buffer)
        keccak_output_buffer <= keccak_state[64*21-1:0];
    else if(shift_output_buffer)
        keccak_output_buffer <= (keccak_output_buffer>>64);
    else
        keccak_output_buffer <= keccak_output_buffer;
end

assign dout_64bit = {keccak_output_buffer[7:0],keccak_output_buffer[15:8],keccak_output_buffer[23:16],keccak_output_buffer[31:24],keccak_output_buffer[39:32],keccak_output_buffer[47:40],keccak_output_buffer[55:48],keccak_output_buffer[63:56]};//keccak_output_buffer[63:0];
/*
// Assuming maximum output length = 21*64 bits
assign dout_64bit_wire = 
                    // For y=0..4 with x=0
                    (state_output_sel==5'd0) ? keccak_state[63+64*5*0+64*0:64*5*0+64*0] :
                    (state_output_sel==5'd1) ? keccak_state[63+64*5*0+64*1:64*5*0+64*1] :
                    (state_output_sel==5'd2) ? keccak_state[63+64*5*0+64*2:64*5*0+64*2] :  
                    (state_output_sel==5'd3) ? keccak_state[63+64*5*0+64*3:64*5*0+64*3] :  
                    (state_output_sel==5'd4) ? keccak_state[63+64*5*0+64*4:64*5*0+64*4] :                                                        

                    // For y=0..4 with x=1
                    (state_output_sel==5'd5) ? keccak_state[63+64*5*1+64*0:64*5*1+64*0] :
                    (state_output_sel==5'd6) ? keccak_state[63+64*5*1+64*1:64*5*1+64*1] :
                    (state_output_sel==5'd7) ? keccak_state[63+64*5*1+64*2:64*5*1+64*2] :  
                    (state_output_sel==5'd8) ? keccak_state[63+64*5*1+64*3:64*5*1+64*3] :  
                    (state_output_sel==5'd9) ? keccak_state[63+64*5*1+64*4:64*5*1+64*4] :

                    // For y=0..4 with x=2
                    (state_output_sel==5'd10) ? keccak_state[63+64*5*2+64*0:64*5*2+64*0] :
                    (state_output_sel==5'd11) ? keccak_state[63+64*5*2+64*1:64*5*2+64*1] :
                    (state_output_sel==5'd12) ? keccak_state[63+64*5*2+64*2:64*5*2+64*2] :  
                    (state_output_sel==5'd13) ? keccak_state[63+64*5*2+64*3:64*5*2+64*3] :  
                    (state_output_sel==5'd14) ? keccak_state[63+64*5*2+64*4:64*5*2+64*4] :

                    // For y=0..4 with x=3
                    (state_output_sel==5'd15) ? keccak_state[63+64*5*3+64*0:64*5*3+64*0] :
                    (state_output_sel==5'd16) ? keccak_state[63+64*5*3+64*1:64*5*3+64*1] :
                    (state_output_sel==5'd17) ? keccak_state[63+64*5*3+64*2:64*5*3+64*2] :  
                    (state_output_sel==5'd18) ? keccak_state[63+64*5*3+64*3:64*5*3+64*3] :  
                    (state_output_sel==5'd19) ? keccak_state[63+64*5*3+64*4:64*5*3+64*4] :

                    // For y=0..4 with x=4
                    (state_output_sel==5'd20) ? keccak_state[63+64*5*4+64*0:64*5*4+64*0] :
                    (state_output_sel==5'd21) ? keccak_state[63+64*5*4+64*1:64*5*4+64*1] :
                    (state_output_sel==5'd22) ? keccak_state[63+64*5*4+64*2:64*5*4+64*2] :  
                    (state_output_sel==5'd23) ? keccak_state[63+64*5*4+64*3:64*5*4+64*3] :  
                                                keccak_state[63+64*5*4+64*4:64*5*4+64*4] ;
always @(posedge clk)
    dout_64bit <= dout_64bit_wire;
*/                                                


wire [63:0] state_matrix[0:4][0:4];

assign {
    state_matrix[4][4],state_matrix[4][3],state_matrix[4][2],state_matrix[4][1],state_matrix[4][0],
    state_matrix[3][4],state_matrix[3][3],state_matrix[3][2],state_matrix[3][1],state_matrix[3][0],
    state_matrix[2][4],state_matrix[2][3],state_matrix[2][2],state_matrix[2][1],state_matrix[2][0],
    state_matrix[1][4],state_matrix[1][3],state_matrix[1][2],state_matrix[1][1],state_matrix[1][0],
    state_matrix[0][4],state_matrix[0][3],state_matrix[0][2],state_matrix[0][1],state_matrix[0][0]} = keccak_state;

endmodule
