`timescale 1ns / 1ps
`define Cipher_idle 3'd0
`define Cipher_wait 3'd1
`define Cipher_Proc_PP 3'd2
`define Cipher_Proc_PP_done 3'd3
`define Cipher_done 3'd4
`define pasta_s 32
`define bitlen 17

// Pasta Permute Wrapper
module Cipher_pasta_permute (
    input                                             Clk_CI,          // Rising edge active clk.
    input                                             Rst_RBI,         // Active low reset.
    input   [63:0]                                    Nonce_DI,        // Nonce.
    input   [2*`pasta_s * `bitlen - 1 :0]             Key_DI,          // Key.
    input   [63:0]                                    block_counter,   // Block Counter.
    input                                             InDataValid_SI,  // Input Data valid.
    output  [`pasta_s * `bitlen - 1 :0]               OutData_Key,     // Key Stream.
    input                                             Start_SI,        // Start signal.
    output                                            Busy_SO,         // Cipher busy. 
    output                                            Finish_SO        // Cipher finish.
    );

    // State variables
    reg [2:0] STATE_SP, STATE_SN;

    // Init pasta permute and busy signals
    reg init_pp;
    reg busy;

    // Pasta permute module variables
    wire rst_pp;
    reg [`pasta_s * `bitlen - 1 :0] key_l, key_r;
    wire [`pasta_s * `bitlen - 1:0] out_l;
    wire [`pasta_s * `bitlen - 1 :0] out_r;
    wire done_pp ;

    // Output Wrapper
    reg [`pasta_s * `bitlen - 1:0] OutData_DO_reg;

 // ---------------------------------------------- byte reverse block -----------------------------------------------------//
 
    wire [63:0] block_counter_reverse;
    reg [63:0] block_counter_reverse_reg;
    byte_reverse counter_reverse(block_counter,block_counter_reverse);  
 
 // ---------------------------------------------- pasta permute block -----------------------------------------------------//

    assign rst_pp = !init_pp;
    pasta_permute pp(
        Clk_CI,
        rst_pp, 
        Nonce_DI,
        block_counter_reverse_reg, 
        key_l,
        key_r,
        out_l,
        out_r,
        done_pp
    );
 
 // -------------------------------------------- STATE Logic ------------------------------------------//
 
    always @(posedge Clk_CI) begin 
        if(!Rst_RBI || Finish_SO || !Busy_SO ) begin//|| (!Busy_SO && !Finish_SO))//|| Finish_SO || !Busy_SO )
            STATE_SP<=`Cipher_idle ;
            key_l <= Key_DI[2*`pasta_s * `bitlen - 1 : `pasta_s * `bitlen];
            key_r <= Key_DI[`pasta_s * `bitlen - 1 : 0];
        end else
            STATE_SP<=STATE_SN;
    end

    always @(posedge Clk_CI)
    begin
        if (STATE_SP == `Cipher_Proc_PP_done) begin 
            OutData_DO_reg [`pasta_s * `bitlen - 1:0]<= out_l; 
        end else if (STATE_SP == `Cipher_idle)  begin  
            OutData_DO_reg <= `pasta_s * `bitlen'd0;
            block_counter_reverse_reg <= 64'd0;
        end else if (STATE_SP == `Cipher_wait) block_counter_reverse_reg <= block_counter_reverse;          
    end

    always @(STATE_SP)
    begin
        if (STATE_SP == `Cipher_Proc_PP) begin init_pp<=1'b1; end
        else begin init_pp<=1'b0; end
    end

    always @(*)
    begin
        case(STATE_SP)
        `Cipher_idle: STATE_SN<=`Cipher_wait;
        `Cipher_wait: STATE_SN<=`Cipher_Proc_PP;
        `Cipher_Proc_PP: begin
            if(done_pp) 
                STATE_SN<=`Cipher_Proc_PP_done;
            else
                STATE_SN<=`Cipher_Proc_PP;
            end
        `Cipher_Proc_PP_done: STATE_SN<=`Cipher_done;                
        `Cipher_done: STATE_SN<=`Cipher_done;	
        default: STATE_SN <= `Cipher_idle;
        endcase
    end

    // Busy Logic
    always @(posedge Clk_CI) begin 
        if(!Rst_RBI )
            busy<=1'b0 ;
        else if(Finish_SO)
            busy<=1'b0 ;
        else if(InDataValid_SI)
            busy<=1'b1;
        else
            busy<=busy;
    end

    // Outputs assignments
    assign Finish_SO = !Rst_RBI ? 0 : (STATE_SP==`Cipher_done);
    assign Busy_SO = !Rst_RBI ? 0 : busy;
    assign OutData_Key = OutData_DO_reg;


endmodule
