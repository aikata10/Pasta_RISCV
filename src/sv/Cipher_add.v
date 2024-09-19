`timescale 1ns / 1ps
`define pasta_s 32
`define bitlen 17

// Addition of Key Stream and Plaintext Wrapper
module Cipher_add (
    input                                             Clk_CI,          // Rising edge active clk.
    input   [`pasta_s * `bitlen - 1 :0]               InData_PTXT_DI,  // Plaintext.
    input   [`pasta_s * `bitlen - 1 :0]               Key_l,           // Key Stream.
    output  [`pasta_s * `bitlen - 1 :0]               OutData_DO,      // Ciphertext.
    input                                             Start_SI,        // Start signal.
    output                                            Finish_SO        // Cipher finish.
);

    wire [`pasta_s * `bitlen - 1 :0] in_modadd1, in_modadd2;
    wire [`pasta_s * `bitlen - 1 :0] OutData_add;
    reg [`pasta_s * `bitlen - 1 :0] OutData;
    reg Finish;
    reg Addition;

    assign in_modadd1 = (Start_SI) ? InData_PTXT_DI[`pasta_s * `bitlen - 1:0] : `pasta_s * `bitlen'd0;
    assign in_modadd2 = (Start_SI) ? Key_l[`pasta_s * `bitlen - 1:0] : `pasta_s * `bitlen'd0;  

    mod_add_wrapper add(
        .clk(Clk_CI),
        .in_modadd1(in_modadd1),
        .in_modadd2(in_modadd2),
        .out_modadd(OutData_add)
    );

    always @(posedge Clk_CI) begin
    if (Start_SI) begin
        Addition<= 1'd1; 
        Finish <= 1'd0;
        OutData <= `pasta_s * `bitlen'd0;
    end else if (Addition) begin
        Addition<= 1'd0;
        Finish <= 1'd1;
        OutData <= OutData_add;
    end else begin
        Addition<= 1'd0; 
        Finish <= 1'd0;
        OutData <= `pasta_s * `bitlen'd0;
    end
    end

    assign Finish_SO = Finish;
    assign OutData_DO = OutData;

endmodule