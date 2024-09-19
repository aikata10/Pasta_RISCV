`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2020 07:37:53 PM
// Design Name: 
// Module Name: keccak_absorb
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


module keccak_absorb(clk, rst, rateInBytes, inputlen_InBytes, delimitedSuffix,
                        din_64bit_raw, din_valid,
                        ready, din_64bit_processed, din_wen, call_keccak_f1600,
                        keccak_round_complete, done);
input clk;
input rst;                      // Active high
input [7:0] rateInBytes;        // Note that maximum rateInBytes = 1344/8 = 168
input [15:0] inputlen_InBytes;  // Message length in bytes. If message is less than 64 bits, then the most significant bits are 0s.
input [7:0] delimitedSuffix;    // Keccak parameter    

input [63:0] din_64bit_raw;
input din_valid;                    // This signal is provided by a data source to indicate that din_64bit_raw is valid

output reg ready;                   // when this signal is high, that means Keccak is ready to absorb.
output [63:0] din_64bit_processed;  // This is properly processed data that ill get written into state buffer.

output reg din_wen;             // Used to write processed 64-bit data to the state buffer.
output reg call_keccak_f1600;   // This signal is used to start Keccak-f1600 on the state variable
input keccak_round_complete;    // This signal comes from Keccak-f1600 after its completion
output done;    // Becomes 1 when the entire input is absorbed.

reg [15:0] messageLen_InBytes;
reg dec_messageLen;
reg [7:0] rate_counter;
reg rst_rate_counter, inc_rate_counter;
wire messageLen_lt_8, messageLen_lte_8, rate_counter_eq, last_rate_byte;

reg [2:0] state, nextstate;
reg delimitedSuffix_used;

//////////////////////////////
assign din_64bit_processed[7:0] = (messageLen_lt_8==1'b0) ? din_64bit_raw[7:0] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd0) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd0) ? din_64bit_raw[7:0] : 8'd0;					 
assign din_64bit_processed[15:8] = (messageLen_lt_8==1'b0) ? din_64bit_raw[15:8] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd1) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd1) ? din_64bit_raw[15:8] :	8'd0;
assign din_64bit_processed[23:16] = (messageLen_lt_8==1'b0) ? din_64bit_raw[23:16] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd2) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd2) ? din_64bit_raw[23:16] : 8'd0;
assign din_64bit_processed[31:24] = (messageLen_lt_8==1'b0) ? din_64bit_raw[31:24] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd3) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd3) ? din_64bit_raw[31:24] : 8'd0;
assign din_64bit_processed[39:32] = (messageLen_lt_8==1'b0) ? din_64bit_raw[39:32] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd4) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd4) ? din_64bit_raw[39:32] : 8'd0;
assign din_64bit_processed[47:40] = (messageLen_lt_8==1'b0) ? din_64bit_raw[47:40] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd5) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd5) ? din_64bit_raw[47:40] : 8'd0;
assign din_64bit_processed[55:48] = (messageLen_lt_8==1'b0) ? din_64bit_raw[55:48] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd6) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd6) ? din_64bit_raw[55:48] : 8'd0;						 
wire [7:0] din_proce_temp = (messageLen_lt_8==1'b0) ? din_64bit_raw[63:56] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd7) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd7) ? din_64bit_raw[63:56] : 8'd0;
assign din_64bit_processed[63:56] = (last_rate_byte) ? {1'b1,din_proce_temp[6:0]} : din_proce_temp;

//////////////////////////////

always @(posedge clk)
begin
    if(rst)
        messageLen_InBytes <= inputlen_InBytes;
    else if(dec_messageLen==1'b1 && messageLen_lt_8==1'b0)
        messageLen_InBytes <= messageLen_InBytes - 8;
    else
        messageLen_InBytes <= messageLen_InBytes;        
end

always @(posedge clk)
begin
	if(rst)
		delimitedSuffix_used <= 1'b0;
	//else if(delimitedSuffix_used==1'b0 && messageLen_lt_8==1'b1)
	else if(delimitedSuffix_used==1'b0 && messageLen_lt_8==1'b1 && state==3'd2) // Note: delimitedSuffix is used only in state=2 (during the first cycle).
		delimitedSuffix_used <= 1'b1;
	else
		delimitedSuffix_used <= delimitedSuffix_used;
end

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
                    

// When message length is less than 8 bytes 
assign messageLen_lt_8 = (messageLen_InBytes < 16'd8) ? 1'b1 : 1'b0;
assign messageLen_lte_8 = (messageLen_InBytes <= 16'd8) ? 1'b1 : 1'b0;
assign rate_counter_eq = (rate_counter==(rateInBytes-8'd8)) ? 1'b1 : 1'b0;
assign last_rate_byte = (messageLen_lt_8==1'b1 && rate_counter_eq==1'b1) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
    if(rst)
        state <= 3'd0;
    else
        state <= nextstate;    
end

always @(state or din_valid or messageLen_lt_8 or rate_counter_eq)
begin
    case(state)
    3'd0: begin // Reset state
            ready<=1;
            rst_rate_counter<=1; inc_rate_counter<=0; dec_messageLen<=0; din_wen<=0; call_keccak_f1600<=0;
        end
    3'd1: begin // Absorb 8 bytes every cycle; Stays in this state till {rate_counter=rateInBytes-8; or remaining message len is <8 bytes}
            ready<=1;
            rst_rate_counter<=0; call_keccak_f1600<=0;
            if(din_valid) begin inc_rate_counter<=1; din_wen<=1; end
            else begin inc_rate_counter<=0; din_wen<=0; end
            if(din_valid==1'b1) dec_messageLen<=1; 
            else dec_messageLen<=0;  
        end
    3'd2: begin // Visited when messageLen was < rate in State1 ; Stay in this state till {rate_counter=rateInBytes-8}. delimitedSuffix_used is used in this state.
            ready<=1;
            rst_rate_counter<=0; call_keccak_f1600<=0;
            inc_rate_counter<=1; din_wen<=1; 
            dec_messageLen<=0; 
        end
    3'd3: begin // Visited after state1 when rate_counter completes the specified rate. Calls keccak-f1600
            ready<=0;
            rst_rate_counter<=1; inc_rate_counter<=0; dec_messageLen<=0; din_wen<=0; call_keccak_f1600<=1;
        end

    3'd4: begin // Absorb complete
            ready<=1;
            rst_rate_counter<=1; inc_rate_counter<=0; dec_messageLen<=0; din_wen<=0; call_keccak_f1600<=0;
        end        
    default: begin // Reset state
            ready<=1;
            rst_rate_counter<=1; inc_rate_counter<=0; dec_messageLen<=0; din_wen<=0; call_keccak_f1600<=0;
        end            
    endcase
end

always @(state or messageLen_lte_8 or messageLen_lt_8 or rate_counter_eq 
        or keccak_round_complete or delimitedSuffix_used)
begin
    case(state)
    3'd0: nextstate <= 3'd1;
    3'd1: begin
            if(rate_counter_eq)
                nextstate <= 3'd3;
            else if(messageLen_lte_8)
                nextstate <= 3'd2;                
            else
                nextstate <= 3'd1;                    
       end  
    3'd2: begin
            if(rate_counter_eq)
                nextstate <= 3'd3;
            else
                nextstate <= 3'd2;                    
       end         
    3'd3: begin
            //if(messageLen_lt_8 && keccak_round_complete)
            if(messageLen_lt_8 && keccak_round_complete && delimitedSuffix_used)
                nextstate <= 3'd4;
            else if(messageLen_lt_8 && keccak_round_complete && delimitedSuffix_used==1'b0) // This is a special case: happens when message length is a multiple of keccak_rate. The delimitedSuffix and following 0s need to be consumed next.
                nextstate <= 3'd2;
            else if(keccak_round_complete)
                nextstate <= 3'd1;
            else
                nextstate <= 3'd3;    
        end

    3'd4: nextstate <= 3'd4;          
    default: nextstate <= 3'd0;          
    endcase
end

assign done = (state==4'd4) ? 1'b1 : 1'b0;

endmodule


/*
module keccak_absorb(clk, rst, rateInBytes, inputlen_InBytes, delimitedSuffix,
                        din_64bit_raw, din_valid,
                        ready, din_64bit_processed, din_wen, call_keccak_f1600,
                        keccak_round_complete, done);
input clk;
input rst;                      // Active high
input [7:0] rateInBytes;        // Note that maximum rateInBytes = 1344/8 = 168
input [15:0] inputlen_InBytes;  // Message length in bytes. If message is less than 64 bits, then the most significant bits are 0s.
input [7:0] delimitedSuffix;    // Keccak parameter    

input [63:0] din_64bit_raw;
input din_valid;                    // This signal is provided by a data source to indicate that din_64bit_raw is valid

output reg ready;                   // when this signal is high, that means Keccak is ready to absorb.
output [63:0] din_64bit_processed;  // This is properly processed data that ill get written into state buffer.

output reg din_wen;             // Used to write processed 64-bit data to the state buffer.
output reg call_keccak_f1600;   // This signal is used to start Keccak-f1600 on the state variable
input keccak_round_complete;    // This signal comes from Keccak-f1600 after its completion
output done;    // Becomes 1 when the entire input is absorbed.

reg [15:0] messageLen_InBytes;
reg dec_messageLen;
reg [7:0] rate_counter;
reg rst_rate_counter, inc_rate_counter;
wire messageLen_lt_8, messageLen_lte_8, rate_counter_eq, last_rate_byte;

reg [2:0] state, nextstate;
reg delimitedSuffix_used;

//////////////////////////////
assign din_64bit_processed[7:0] = (messageLen_lt_8==1'b0) ? din_64bit_raw[7:0] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd0) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd0) ? din_64bit_raw[7:0] : 8'd0;					 
assign din_64bit_processed[15:8] = (messageLen_lt_8==1'b0) ? din_64bit_raw[15:8] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd1) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd1) ? din_64bit_raw[15:8] :	8'd0;
assign din_64bit_processed[23:16] = (messageLen_lt_8==1'b0) ? din_64bit_raw[23:16] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd2) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd2) ? din_64bit_raw[23:16] : 8'd0;
assign din_64bit_processed[31:24] = (messageLen_lt_8==1'b0) ? din_64bit_raw[31:24] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd3) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd3) ? din_64bit_raw[31:24] : 8'd0;
assign din_64bit_processed[39:32] = (messageLen_lt_8==1'b0) ? din_64bit_raw[39:32] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd4) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd4) ? din_64bit_raw[39:32] : 8'd0;
assign din_64bit_processed[47:40] = (messageLen_lt_8==1'b0) ? din_64bit_raw[47:40] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd5) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd5) ? din_64bit_raw[47:40] : 8'd0;
assign din_64bit_processed[55:48] = (messageLen_lt_8==1'b0) ? din_64bit_raw[55:48] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd6) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd6) ? din_64bit_raw[55:48] : 8'd0;						 
wire [7:0] din_proce_temp = (messageLen_lt_8==1'b0) ? din_64bit_raw[63:56] : 
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]==3'd7) ? delimitedSuffix :
						 (delimitedSuffix_used==1'b0 && messageLen_InBytes[2:0]>3'd7) ? din_64bit_raw[63:56] : 8'd0;
assign din_64bit_processed[63:56] = (last_rate_byte) ? {1'b1,din_proce_temp[6:0]} : din_proce_temp;

//////////////////////////////

always @(posedge clk)
begin
    if(rst)
        messageLen_InBytes <= inputlen_InBytes;
    else if(dec_messageLen==1'b1 && messageLen_lt_8==1'b0)
        messageLen_InBytes <= messageLen_InBytes - 8;
    else
        messageLen_InBytes <= messageLen_InBytes;        
end

always @(posedge clk)
begin
	if(rst)
		delimitedSuffix_used <= 1'b0;
	else if(delimitedSuffix_used==1'b0 && messageLen_lt_8==1'b1)
		delimitedSuffix_used <= 1'b1;
	else
		delimitedSuffix_used <= delimitedSuffix_used;
end

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
                    

// When message length is less than 8 bytes 
assign messageLen_lt_8 = (messageLen_InBytes < 16'd8) ? 1'b1 : 1'b0;
assign messageLen_lte_8 = (messageLen_InBytes <= 16'd8) ? 1'b1 : 1'b0;
assign rate_counter_eq = (rate_counter==(rateInBytes-8'd8)) ? 1'b1 : 1'b0;
assign last_rate_byte = (messageLen_lt_8==1'b1 && rate_counter_eq==1'b1) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
    if(rst)
        state <= 3'd0;
    else
        state <= nextstate;    
end

always @(state or din_valid or messageLen_lt_8 or rate_counter_eq)
begin
    case(state)
    3'd0: begin // Reset state
            ready<=1;
            rst_rate_counter<=1; inc_rate_counter<=0; dec_messageLen<=0; din_wen<=0; call_keccak_f1600<=0;
        end
    3'd1: begin // Absorb 8 bytes every cycle; Stays in this state till {rate_counter=rateInBytes-8; or remaining message len is <8 bytes}
            ready<=1;
            rst_rate_counter<=0; call_keccak_f1600<=0;
            if(din_valid) begin inc_rate_counter<=1; din_wen<=1; end
            else begin inc_rate_counter<=0; din_wen<=0; end
            if(din_valid==1'b1) dec_messageLen<=1; 
            else dec_messageLen<=0;  
        end
    3'd2: begin // Visited when messageLen was < rate in State1 ; Stay in this state till {rate_counter=rateInBytes-8}
            ready<=1;
            rst_rate_counter<=0; call_keccak_f1600<=0;
            inc_rate_counter<=1; din_wen<=1; 
            dec_messageLen<=0; 
        end
    3'd3: begin // Visited after state1 when rate_counter completes the specified rate. Calls keccak-f1600
            ready<=0;
            rst_rate_counter<=1; inc_rate_counter<=0; dec_messageLen<=0; din_wen<=0; call_keccak_f1600<=1;
        end

    3'd4: begin // Absorb complete
            ready<=1;
            rst_rate_counter<=1; inc_rate_counter<=0; dec_messageLen<=0; din_wen<=0; call_keccak_f1600<=0;
        end        
    default: begin // Reset state
            ready<=1;
            rst_rate_counter<=1; inc_rate_counter<=0; dec_messageLen<=0; din_wen<=0; call_keccak_f1600<=0;
        end            
    endcase
end

always @(state or messageLen_lte_8 or messageLen_lt_8 or rate_counter_eq 
        or keccak_round_complete)
begin
    case(state)
    3'd0: nextstate <= 3'd1;
    3'd1: begin
            if(rate_counter_eq)
                nextstate <= 3'd3;
            else if(messageLen_lte_8)
                nextstate <= 3'd2;                
            else
                nextstate <= 3'd1;                    
       end  
    3'd2: begin
            if(rate_counter_eq)
                nextstate <= 3'd3;
            else
                nextstate <= 3'd2;                    
       end         
    3'd3: begin
            if(messageLen_lt_8 && keccak_round_complete)
                nextstate <= 3'd4;
            else if(keccak_round_complete)
                nextstate <= 3'd1;
            else
                nextstate <= 3'd3;    
        end

    3'd4: nextstate <= 3'd4;          
    default: nextstate <= 3'd0;          
    endcase
end

assign done = (state==4'd4) ? 1'b1 : 1'b0;

endmodule
*/