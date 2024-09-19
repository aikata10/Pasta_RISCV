`timescale 1ns/1ps

`include "ibex.svh"

module instr_rom_wrapper (
    input  logic clk_i,
    input  logic rst_ni,
    bus_if.slave bus
);
  // Immediatly assign a grant
  assign bus.gnt = bus.req;
  // We do not generate errors
  assign bus.err = 1'b0;
  // Generate Rvalid one cycle after request
  always_ff @(posedge clk_i) begin
    bus.rvalid <= bus.req;
  end

 SPLD130_8192X32BM1A_BC_wrapper #(
    .ROMCODE  ( "./_program/rom_0.patt" )
  ) rom_i (
    .CK  ( clk_i          ),
    .CSB ( bus.req        ),
    .A   ( bus.addr[14:2] ),
    .DO  ( bus.rdata      )
  );
endmodule
