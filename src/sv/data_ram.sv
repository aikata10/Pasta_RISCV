`timescale 1ns/1ps

module data_ram_wrapper #(
  parameter N_RAMS = 4
) (
    input  logic clk_i,
    input  logic rst_ni,
    bus_if.slave bus
);
  logic [N_RAMS-1:0] cs_q;
  logic [31:0] data_rdata[N_RAMS];

  // Generate combined write enable signal on byte-level
  logic [3:0] wbe;
  assign wbe = {4{bus.we}} & bus.be;

  // Immediatly assign a grant
  assign bus.gnt = bus.req;
  // We do not generate errors
  assign bus.err = 1'b0;

  genvar i;
  generate
    for (i = 0; i < N_RAMS; i++) begin
      // Generate Chip Select logic
      logic cs;
      assign cs = bus.req & (bus.addr[15:14] == i);

      SHLD130_4096X8X4BM2_wrapper data_ram_i (
        .CK    ( clk_i          ),
        .CSB   ( cs             ),
        .WEB   ( ~wbe           ),
        .A     ( bus.addr[13:2] ),
        .DI    ( bus.wdata      ),
        .DO    ( data_rdata[i]  )
      );

      always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
          cs_q[i] <= 1'b0;
        end else begin
          cs_q[i] <= cs;
        end
      end
    end
  endgenerate

  // Output Mux
  integer j;
  always_comb begin
    // Model output logic
    bus.rdata = 32'b0;
    for(j = 0; j < N_RAMS; j++)
      if(cs_q[j]) bus.rdata = data_rdata[j];
  end

  // Generate Rvalid one cycle after request
  assign bus.rvalid = |cs_q;
endmodule
