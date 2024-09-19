//-----------------------------------------------------------------------------
//
// 1:N Bus multiplexter
//
// Connects one master with N slaves. In case there is a request but the
// the address is not assigned to one slave, the multiplexer acknowledges
// the requests and sends an error signal in the next cycle.
//
//-----------------------------------------------------------------------------

module bus_mux1mNs #(
  parameter int N_SLAVES             = 4,
  parameter int START_ADDR[N_SLAVES] = '{0},
  parameter int MASK[N_SLAVES]       = '{0}
) (
  input logic   clk_i,
  input logic   rst_ni,
  bus_if.slave  master,
  bus_if.master slave[N_SLAVES]
);

  logic [N_SLAVES-1:0] mux_gnt, mux_rvalid, mux_req, mux_err;
  logic [31:0] local_rdata[N_SLAVES];
  logic bus_err_rvalid_n, bus_err_rvalid_q;

  genvar i;
  generate
    for (i = 0; i < N_SLAVES; i++) begin
      assign mux_req[i]     = master.req & ((master.addr & MASK[i]) == START_ADDR[i]);
      assign slave[i].req   = mux_req[i];
      assign slave[i].addr  = master.addr;
      assign slave[i].we    = master.we;
      assign slave[i].be    = master.be;
      assign slave[i].wdata = master.wdata;

      // Response channel from slave assigned to helper arrays to support
      // reducing to a single signal
      assign mux_gnt[i]     = slave[i].gnt;
      assign mux_err[i]     = slave[i].err;
      assign mux_rvalid[i]  = slave[i].rvalid;
      assign local_rdata[i] = slave[i].rdata;
    end
  endgenerate

  // Multiplex rdata signals from all slaves to one final rdata signal for the
  // master interface
  integer j;
  always_comb begin
    master.rdata = '0;
    for (j = 0; j < N_SLAVES; j++) begin
      master.rdata |= local_rdata[j];
    end
  end

  // Reduce rvalid signal and err signal from all slaves to the master
  // Include error signal from bus error detect here
  assign master.rvalid = |mux_rvalid | bus_err_rvalid_q;
  assign master.err    = |mux_err    | bus_err_rvalid_q;

  always_comb begin
    // Return gnt from the slaves
    master.gnt       = |mux_gnt;
    bus_err_rvalid_n = 1'b0;
    // Bus error because there was a master request but no slave responed.
    // Acknowledge the request via gnt, give response with err in next cycle
    if(master.req & ~|mux_req) begin
      master.gnt       = 1'b1;
      bus_err_rvalid_n = 1'b1;
    end
  end

  // FF for delayed rvalid cycle in error case
  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if(!rst_ni) begin
      bus_err_rvalid_q <= 1'b0;
    end else begin
      bus_err_rvalid_q <= bus_err_rvalid_n;
    end
  end
endmodule
