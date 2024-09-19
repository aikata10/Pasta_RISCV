`timescale 1ns/1ps

`include "ibex.svh"

module IbexASIC (
    input logic       Clk_CI,
    input logic       Rst_RBI,
    output logic      Eoc_SO,
    output logic      GPO_DO_0,
    output logic      GPO_DO_1,
    output logic      GPO_DO_2,
    output logic      GPO_DO_3,
    output logic      ParO_DO_0,
    output logic      ParO_DO_1,
    output logic      ParO_DO_2,
    output logic      ParO_DO_3,
    output logic      ParO_DO_4,
    output logic      ParO_DO_5,
    output logic      ParO_DO_6,
    output logic      ParO_DO_7,
    output            ParO_valid_S0
);

  bus_if instr_if(), data_if(),master_ciph_if();
  ibex_core #(
      .PMPEnable      ( 1'b0         ),
      .RV32M          ( 1'b0         ),
      .DmHaltAddr     ( 32'h00000000 ),
      .DmExceptionAddr( 32'h00000000 )
    ) u_core (
      .clk_i                 (Clk_CI),
      .rst_ni                (Rst_RBI),

      .test_en_i             ('b0),

      .hart_id_i             (32'b0),
      // First instruction executed is at 0x0 + 0x80
      .boot_addr_i           (`ROM_START),

      .instr_req_o           (instr_if.req   ),
      .instr_gnt_i           (instr_if.gnt   ),
      .instr_rvalid_i        (instr_if.rvalid),
      .instr_addr_o          (instr_if.addr  ),
      .instr_rdata_i         (instr_if.rdata ),
      .instr_err_i           (instr_if.err   ),

      .data_req_o            (data_if.req   ),
      .data_gnt_i            (data_if.gnt   ),
      .data_rvalid_i         (data_if.rvalid),
      .data_we_o             (data_if.we    ),
      .data_be_o             (data_if.be    ),
      .data_addr_o           (data_if.addr  ),
      .data_wdata_o          (data_if.wdata ),
      .data_rdata_i          (data_if.rdata ),
      .data_err_i            (data_if.err   ),

      .irq_software_i        (1'b0),
      .irq_timer_i           (1'b0),
      .irq_external_i        (1'b0),
      .irq_fast_i            (15'b0),
      .irq_nm_i              (1'b0),

      .debug_req_i           ('b0),

      .fetch_enable_i        ('b1),
      .core_sleep_o          ()
  );
  
  bus_if slaves[7]();

  bus_mux1mNs #(
    .N_SLAVES ( 7 ),
    .START_ADDR ( '{
      `ROM_START,
      `RAM_START,
      `EOC_START,
      `GPO_START,
      `PARO_START,
      `LFSR_START,
      `CIPHER_START
    } ),
    .MASK ( '{
      `ROM_MASK,
      `RAM_MASK,
      `EOC_MASK,
      `GPO_MASK,
      `PARO_MASK,
      `LFSR_MASK,
      `CIPHER_MASK
    } )
  ) bus_mux (
    .clk_i  ( Clk_CI  ),
    .rst_ni ( Rst_RBI ),
    .master ( data_if ),
    .slave  ( slaves  )
  );

  bus_if rom_if();
  bus_arbiter2m1s #(
    .SLAVE_START( `ROM_START ),
    .SLAVE_SIZE ( `ROM_SIZE  )
  ) arbiter_i (
    .clk_i   ( Clk_CI      ),
    .rst_ni  ( Rst_RBI     ),
    .master1 ( instr_if    ),
    .master2 ( slaves[0]   ),
    .slave   ( rom_if      )
  );

  instr_rom_wrapper instr_rom_i (
    .clk_i    ( Clk_CI  ),
    .rst_ni   ( Rst_RBI ),
    .bus      ( rom_if  )
  );

  bus_if dma_if();
  bus_arbiter2m1s #(
    .SLAVE_START( `RAM_START ),
    .SLAVE_SIZE ( `RAM_SIZE  )
  ) arbiter_ic (
    .clk_i   ( Clk_CI      ),
    .rst_ni  ( Rst_RBI     ),
    .master1 (  slaves[1]    ),
    .master2 ( master_ciph_if   ),
    .slave   (   dma_if   )
  );


  data_ram_wrapper #(
    .N_RAMS ( 4 )
  ) data_ram_i (
    .clk_i  ( Clk_CI      ),
    .rst_ni ( Rst_RBI     ),
    .bus    ( dma_if   )
  );

  eoc_controller eoc_i (
    .clk_i  ( Clk_CI    ),
    .rst_ni ( Rst_RBI   ),
    .bus    ( slaves[2] ),
    .eoc_o  ( Eoc_SO    )
  );

  gpo_peripheral gpo_i (
    .clk_i  ( Clk_CI      ),
    .rst_ni ( Rst_RBI     ),
    .bus    ( slaves[3]   ),
    .gpo_o  ( { GPO_DO_3, 
                GPO_DO_2,
                GPO_DO_1,
                GPO_DO_0} )
  );

  parallel_out par_out_i (
    .clk_i        ( Clk_CI        ),
    .rst_ni       ( Rst_RBI       ),
    .bus          ( slaves[4]     ),
    .parout_valid ( ParO_valid_S0 ),
    .parout       ( { ParO_DO_7,
                       ParO_DO_6,
                       ParO_DO_5,
                       ParO_DO_4,
                       ParO_DO_3,
                       ParO_DO_2,
                       ParO_DO_1,
                       ParO_DO_0 })
  );

  lfsr_peripheral lfsr_i (
    .clk_i  ( Clk_CI      ),
    .rst_ni ( Rst_RBI     ),
    .bus    ( slaves[5]   )
  );
  
  Cipher_peripheral Cipher_i (
    .clk_i  ( Clk_CI      ),
    .rst_ni ( Rst_RBI     ),
    .bus    ( slaves[6]   ),
    .bus_M    ( master_ciph_if) 
  );

endmodule
