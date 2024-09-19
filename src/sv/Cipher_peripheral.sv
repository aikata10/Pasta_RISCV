`timescale 1ns/1ps
`define bitlen 17
`define pasta_s 32
`define counterMaxRead ((`pasta_s * `bitlen) / 32) + 2 // Reading PTXT from RAM
`define counterMaxWrite ((`pasta_s * `bitlen) / 32) + 1 // Sending Ciphertext to core

// Pasta Peripheral
module Cipher_peripheral (
    input  logic       clk_i,
    input  logic       rst_ni,
    bus_if.slave       bus,
    bus_if.master      bus_M
);

    // Inputs and Outputs Cipher Pasta Permute Wrapper
    logic Start;
    logic InDataValid_SP, InDataValid_SN;
    logic Busy_S,Finish_PP;
    logic [63:0] Nonce;
    logic [2*`pasta_s * `bitlen - 1 :0] Key;
    logic [`pasta_s * `bitlen - 1 :0] OutData_Key;

    // Outputs Cipher Addition Wrapper
    logic Finish_S;
    logic [`pasta_s * `bitlen - 1 :0] OutData_D;

    // Key&Nonce and PTXT registers
    logic [2*`pasta_s * `bitlen + 63:0] key_nonce_SN,key_nonce_SP;
    logic [`pasta_s * `bitlen - 1 :0] Indata_PTXT_SN,Indata_PTXT_SP;

    // Bus Slave Signals 
    logic [31:0] DataOut_DN,DataOut_DP;
    logic rvalid_SP,rvalid_SN;

    // OutData (Ciphertext) used for sending data to the core
    logic [`pasta_s * `bitlen - 1 :0] final_out_SN,final_out_SP;

    // Control signal for sending Ciphertext
    logic req_proc_SN,req_proc_SP;

    // Control signal for reading Key and Nonce
    logic req_read_SN,req_read_SP;

    // Counter for reading PTXT from RAM 
    logic [7:0] read_counter_SN,read_counter_SP;

    // Counter for sending Ciphertext to core 
    logic [7:0] counter_SN,counter_SP;

    // Control signals to increment reading and writing counters
    logic inc_ctr,read_ctr;

    // Present stage and next stage for the block counter
    logic [63:0] block_counter_SN, block_counter_SP;


    // Signals handling communication with the core
    logic BusRead_S,BusWrite_S;
    logic [31:0] PTXT_addr,PTXT_addr_reg;
    logic read_ptxt;

    assign BusRead_S  = (bus.req && !bus.we && bus.addr[7:0] == 8'h00); // Signal to Start acivate the Cipher
    assign BusWrite_S  = (bus.req && bus.we && bus.addr[19:4] == 16'h8010); // Signal to Read the Nonce and Key values
    assign PTXT_addr  =  (bus.req && bus.we && bus.addr[19:0] == 20'h8010c) ? bus.wdata : PTXT_addr_reg; // Signal to receive the address of the  PTXT in the RAM
    assign read_ptxt =(bus.req && bus.we && bus.addr[19:0] == 20'h8010c); // Signal to Start the read operation for block couneter and PTXT
  
    // Slave Bus assignments
    assign bus.gnt = bus.req;  // Immediatly assign a grant (output)
    // We do not generate errors
    assign bus.err = 1'b0;
    // Signal rvalid and set data
    assign bus.rdata  = DataOut_DP; 
    assign bus.rvalid = rvalid_SP;

    // rvalid_set is telling when the chunks are ready to be read from the SW side
    logic rvalid_set;
    assign rvalid_set = !bus.we && rvalid_SP;
    
    //Master Bus assignments to read data from BRAM 
    logic read_req_SN,read_req_SP,Read_done;
    logic [31:0] read_addr_SN,read_addr_SP;
    
    assign bus_M.req=read_req_SP;
    assign bus_M.addr = read_addr_SP;
    assign bus_M.we=0;
    assign bus_M.be=0;
    assign bus_M.wdata=0;
  
    // Counters
    assign read_ctr =   rst_ni ? (read_counter_SP<`counterMaxRead && read_counter_SP!=8'd0) : 0; //Used for reading PTXT and block counter
    assign Read_done=(read_counter_SP == `counterMaxRead);

    assign inc_ctr =  req_proc_SP && rst_ni && !rvalid_set ? (counter_SP<`counterMaxWrite && counter_SP!=8'd0) : 0;//Used for writing CTXT 

    
    // Ciphertext Generation Wrappers
    Cipher_pasta_permute pasta_permute (
      .Clk_CI       		(clk_i),
      .Rst_RBI			    (rst_ni),
      .Key_DI				    (Key),
      .Nonce_DI			    (Nonce),
      .block_counter    (block_counter_SP),
      .InDataValid_SI		(InDataValid_SP),  
      .OutData_Key			(OutData_Key),
      .Start_SI			    (Start),
      .Busy_SO			    (Busy_S),
      .Finish_SO			  (Finish_PP) 
    );


    Cipher_add ciph_add (
      .Clk_CI       		(clk_i),
      .InData_PTXT_DI   (Indata_PTXT_SP),
      .Key_l				    (OutData_Key), 
      .OutData_DO			  (OutData_D),
      .Start_SI			    (Finish_PP),
      .Finish_SO			  (Finish_S) 
    );



    //Assignments to Cipher inputs
    assign Key = key_nonce_SP[2*`pasta_s * `bitlen + 63 :64];
    assign Nonce= key_nonce_SP[63:0]; 
    assign Start=BusRead_S; 
    
    always_comb begin

      // Driving DataValid Signal to Start Pasta Permute
      if(Busy_S || Finish_PP ) 
        InDataValid_SN  = 1'b0;
      else if (Start) 
        InDataValid_SN  = 1'b1;
      else
      InDataValid_SN=InDataValid_SP;
      
    
      // ---------------------------------------------- Sending data to core-----------------------------------------------------//
      if (Finish_S || rvalid_set) begin 
        rvalid_SN	  =1'b0;
        DataOut_DN = final_out_SP[`pasta_s * `bitlen - 1:`pasta_s * `bitlen - 32];
    end else if (req_read_SP ) begin
        rvalid_SN	  =1'b1;
        DataOut_DN = '{default: 0};
    end else if (inc_ctr) begin 
        rvalid_SN	  =1'b1;
        DataOut_DN = final_out_SP[`pasta_s * `bitlen - 1:`pasta_s * `bitlen - 32];
    end else  begin  
        rvalid_SN    =1'b0;
        DataOut_DN   = '{default: 0};
      end
      
      
    if(Start)   begin
      counter_SN=8'd0;
      final_out_SN=`pasta_s * `bitlen'd0;
      end
      else if(Finish_S ) begin
      counter_SN=counter_SP+1'b1;
      final_out_SN= OutData_D;
      end
      else if(inc_ctr ) begin
      counter_SN=counter_SP+1'b1;
      final_out_SN={final_out_SP[`pasta_s * `bitlen - 33:0],32'b0};
      end
      else begin
      counter_SN=counter_SP; 
      final_out_SN=final_out_SP;
      end
        
      if(bus.req)
      req_proc_SN=1'b1;
      else if(rvalid_SP)
      req_proc_SN=1'b0;
      else
      req_proc_SN=req_proc_SP;
      
    // ---------------------------------------------- Read Key and Nonce from bus-----------------------------------------------------//
      if (BusWrite_S && !read_ptxt  )  begin 
        key_nonce_SN = {key_nonce_SP [2 * `pasta_s * `bitlen + 31 :0],bus.wdata};
        req_read_SN =1'b1;
      end else begin
        key_nonce_SN = key_nonce_SP;
        req_read_SN =(1'b0 || read_ptxt);
      end
      
    // ---------------------------------------------- Read Plaintext from RAM-----------------------------------------------------//
    if(Finish_S) begin
      read_counter_SN=8'd0;
      Indata_PTXT_SN=`pasta_s * `bitlen'd0;
      read_req_SN=1'b0;
      read_addr_SN=PTXT_addr;
      block_counter_SN = block_counter_SP + 1'b1;
    end
    else if(Start ) begin
      read_counter_SN=read_counter_SP+1'b1;
      Indata_PTXT_SN= {Indata_PTXT_SP[`pasta_s * `bitlen - 33 :0],bus_M.rdata};
      read_req_SN=1'b1;
      read_addr_SN=PTXT_addr;
      block_counter_SN = block_counter_SP;
    end
    else if(read_ctr ) begin 
      read_counter_SN=read_counter_SP+1'b1;
      Indata_PTXT_SN= {Indata_PTXT_SP[`pasta_s * `bitlen - 33 :0],bus_M.rdata};
      read_req_SN=1'b1;
      read_addr_SN=read_addr_SP+4'd4;
      block_counter_SN = block_counter_SP;
    end
    else if(Read_done)begin
      read_counter_SN=0; 
      Indata_PTXT_SN=Indata_PTXT_SP;
      read_req_SN=1'b0;
      read_addr_SN=PTXT_addr; 
    end 
    else if (BusWrite_S && !read_ptxt) begin
      read_counter_SN=read_counter_SP; 
      Indata_PTXT_SN=Indata_PTXT_SP;
      block_counter_SN = 64'd0;
      read_req_SN=1'b0;
      read_addr_SN=read_addr_SP;
    end
    else begin
      read_counter_SN=read_counter_SP; 
      Indata_PTXT_SN=Indata_PTXT_SP;
      block_counter_SN = block_counter_SP;
      read_req_SN=1'b0;
      read_addr_SN=read_addr_SP;
    end
    
    end 
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if(!rst_ni) begin
        InDataValid_SP   <= 1'b0;
        rvalid_SP   <= 1'b0;
        DataOut_DP  <='{default: 0};
        PTXT_addr_reg<='{default: 0};
        counter_SP<='{default:0};
        final_out_SP<='{default:0};
        req_proc_SP<=1'b0;
        key_nonce_SP<='{default:0};
        req_read_SP<=1'b0;
        Indata_PTXT_SP<='{default:0};
        block_counter_SP<='{default:0};
        read_req_SP<=1'b0;
        read_addr_SP<='{default:0};
        read_counter_SP<='{default:0};
      end else begin
        InDataValid_SP   <= InDataValid_SN;
        rvalid_SP   <= rvalid_SN;
        DataOut_DP  <=DataOut_DN;
        PTXT_addr_reg<=PTXT_addr;
        counter_SP<=counter_SN;
        final_out_SP<=final_out_SN;
        req_proc_SP<=req_proc_SN;
        key_nonce_SP<=key_nonce_SN;
        req_read_SP<=req_read_SN;
        Indata_PTXT_SP<=Indata_PTXT_SN;
        read_req_SP<=read_req_SN;
        read_addr_SP<=read_addr_SN;
        read_counter_SP<=read_counter_SN;
        block_counter_SP <= block_counter_SN;
      end
    
    
    
    
  end
endmodule

