`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2020 10:29:30 PM
// Design Name: 
// Module Name: keccak_round_constants
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


module keccak_round_constants(round_nr, round_constant);
input [4:0] round_nr;
output [63:0] round_constant;

assign round_constant = 
		(round_nr==5'd0) ? 64'h0000000000000001 :
	    (round_nr==5'd1) ? 64'h0000000000008082 :
	    (round_nr==5'd2) ? 64'h800000000000808A :
	    (round_nr==5'd3) ? 64'h8000000080008000 :
	    (round_nr==5'd4) ? 64'h000000000000808B :
	    (round_nr==5'd5) ? 64'h0000000080000001 :
	    (round_nr==5'd6) ? 64'h8000000080008081 :
	    (round_nr==5'd7) ? 64'h8000000000008009 :
	    (round_nr==5'd8) ? 64'h000000000000008A :
	    (round_nr==5'd9) ? 64'h0000000000000088 :
	    (round_nr==5'd10) ? 64'h0000000080008009 :
	    (round_nr==5'd11) ? 64'h000000008000000A :
	    (round_nr==5'd12) ? 64'h000000008000808B :
	    (round_nr==5'd13) ? 64'h800000000000008B :
	    (round_nr==5'd14) ? 64'h8000000000008089 :
	    (round_nr==5'd15) ? 64'h8000000000008003 :
	    (round_nr==5'd16) ? 64'h8000000000008002 :
	    (round_nr==5'd17) ? 64'h8000000000000080 :
	    (round_nr==5'd18) ? 64'h000000000000800A :
	    (round_nr==5'd19) ? 64'h800000008000000A :
	    (round_nr==5'd20) ? 64'h8000000080008081 :
	    (round_nr==5'd21) ? 64'h8000000000008080 :
	    (round_nr==5'd22) ? 64'h0000000080000001 :
	    (round_nr==5'd23) ? 64'h8000000080008008 : 64'h0;
	    
endmodule
