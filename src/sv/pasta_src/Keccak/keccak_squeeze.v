`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/27/2020 11:22:46 AM
// Design Name: 
// Module Name: keccak_squeeze
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

/*
# === Squeeze out all the output blocks ===
    while(outputByteLen > 0):
        blockSize = min(outputByteLen, rateInBytes)
        outputBytes = outputBytes + state[0:blockSize]
        outputByteLen = outputByteLen - blockSize
        if (outputByteLen > 0):
            state = KeccakF1600(state)
    return outputBytes
*/

// Note: Data output from Keccak squeeze happens in 64-bit words every cycle.    
module keccak_squeeze(clk,  rounds_done,rst, rateInBytes, outputLen_InBytes, keccak_squeeze_resume,
                        call_keccak_f1600, keccak_round_complete, 
                        state_reg_sel, we_output_buffer, shift_output_buffer, dout_valid, done);
input clk;
input rst,rounds_done;                       // Active high
input [7:0] rateInBytes;         // Note that maximum rateInBytes = 1344/8 = 168
input [15:0] outputLen_InBytes;  // Output length in bytes. If output is less than 64 bits, then the most significant bits of 64-bit word are 0s.
input keccak_squeeze_resume;     // This is used to 'resume' Keccak squeeze after a pause. Useful to generate PRNG in short chunks.

output reg call_keccak_f1600;    // This signal is used to start Keccak-f1600 on the state variable
input keccak_round_complete;     // This signal comes from Keccak-f1600 after its completion
output [4:0] state_reg_sel;      // This is used to select State[0]..to..State[rate] (at most). Note that only 64-bits are output every cycle.
output we_output_buffer;       // Used to write keccak_state into keccak_output_buffer
output shift_output_buffer;    // Used to shift the keccak_output_buffer in 64 bits such that one word is output
output reg dout_valid;           // This signal is used to write Keccak-squeeze output
output done;                     // Becomes 1 when the entire input is absorbed.


reg [16:0] outputLen_InBytes_reg;   // 1 bit extra is used for sign: + or -
reg dec_outputLen;
wire outputLen_lte_8, outputLen_lte_0;
reg [7:0] rate_counter;
reg rst_rate_counter, inc_rate_counter;
reg [3:0] state, nextstate;
wire rate_counter_eq;

reg we_output_buffer;       // Used to write keccak_state into keccak_output_buffer
reg shift_output_buffer;    // Used to shift the keccak_output_buffer in 64 bits such that one word is output


always @(posedge clk)
begin
    if(rst)
        outputLen_InBytes_reg <= {1'b0,outputLen_InBytes};
    else if(dec_outputLen==1'b1 && outputLen_lte_8==1'b0)
        outputLen_InBytes_reg <= outputLen_InBytes_reg - 17'd8;
    else
        outputLen_InBytes_reg <= outputLen_InBytes_reg;        
end

assign outputLen_lte_8 = (outputLen_InBytes_reg <= 17'd8) ? 1'b1 : 1'b0;
assign outputLen_lte_0 = (outputLen_InBytes_reg[16]==1'b1 || outputLen_InBytes_reg==17'd0);
assign rate_counter_eq = (rate_counter==(rateInBytes-8'd8)) ? 1'b1 : 1'b0;
assign state_reg_sel = rate_counter[7:3];

always @(posedge clk)
begin
    if(rst)
        rate_counter <= 8'd0;
    else if(rst_rate_counter)
        rate_counter <= 8'd0;
    else if(inc_rate_counter)
        rate_counter <= rate_counter + 8'd8; 
    else
        rate_counter <= rate_counter;
end

always @(posedge clk)
begin
    if(rst)
        state <= 4'd0;
    else
        state <= nextstate;    
end

always @(state)
begin
    case(state)
    4'd0: begin // Reset state
            rst_rate_counter<=1; call_keccak_f1600<=0;
            inc_rate_counter<=0; dout_valid<=0; dec_outputLen<=0; 
            we_output_buffer<=1; shift_output_buffer<=0;
        end

    4'd1: begin // Start squeeze; Send state words one-by-one till min(outputLen, rateInBytes); Also start the next state permutation in [parallel. Note: state permutation takes more cycles than squeeze.
            rst_rate_counter<=0; call_keccak_f1600<=1;
            inc_rate_counter<=1; dout_valid<=!rounds_done & 1; dec_outputLen<=1; 
            we_output_buffer<=0; shift_output_buffer<=1;
        end
        
    4'd2: begin // Jump to this state from State-1 unless outputLen_lte_0. Continue Keccak-f1600, always.
            rst_rate_counter<=1; call_keccak_f1600<=1;
            inc_rate_counter<=0; dout_valid<=0; dec_outputLen<=0;
            we_output_buffer<=0; shift_output_buffer<=0; 
        end

    4'd3: begin // Wait in this state for Data-receiver to provide 'resume' signal. With this we can 'pause' generation of long PRNG string.
            rst_rate_counter<=0; call_keccak_f1600<=0;
            inc_rate_counter<=0; dout_valid<=0; dec_outputLen<=0;
            we_output_buffer<=1; shift_output_buffer<=0; 
        end
        
    4'd4: begin // End state: From state1 to this state when outputLen_lte_0. 
            rst_rate_counter<=1; call_keccak_f1600<=0;
            inc_rate_counter<=0; dout_valid<=0; dec_outputLen<=0; 
            we_output_buffer<=0; shift_output_buffer<=0;
        end
    default: begin // Reset
            rst_rate_counter<=1; call_keccak_f1600<=0;
            inc_rate_counter<=0; dout_valid<=0; dec_outputLen<=0;
            we_output_buffer<=0; shift_output_buffer<=0; 
        end
    endcase
end

always @(state or rate_counter_eq or outputLen_lte_8 
        or keccak_round_complete or keccak_squeeze_resume)
begin
    case(state)
    4'd0: begin
            if(keccak_squeeze_resume)
                nextstate <= 4'd1;
            else
                nextstate <= 4'd0;
         end       

    4'd1: begin // Stay in this state outputLen is generated; or KeccakRate is completed.
            if(outputLen_lte_8)
                nextstate <= 4'd4;
            else if(rate_counter_eq)
                nextstate <= 4'd2;
            else
                nextstate <= 4'd1;    
         end
         
    4'd2: begin 
            if(keccak_round_complete)
                nextstate <= 4'd3;
            else
                nextstate <= 4'd2;    
         end
    4'd3: begin 
            if(keccak_squeeze_resume)
                nextstate <= 4'd1;
            else
                nextstate <= 4'd3;    
         end         
    4'd4: nextstate <= 4'd4;
    default: nextstate <= 4'd0;
    endcase
end

assign done = rst || (state==4'd4);
    
endmodule
