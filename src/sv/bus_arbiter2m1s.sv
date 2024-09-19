module bus_arbiter2m1s  #(
  parameter SLAVE_START = 32'h0,
  parameter SLAVE_SIZE  = 32'h8000
) (
  input clk_i,
  input rst_ni,

  bus_if.slave  master1,
  bus_if.slave  master2,
  bus_if.master slave
);
  localparam SLAVE_MASK = ~(SLAVE_SIZE - 1);

  // Generate selection signals from both masters
  logic master1_sel, master2_sel;
  assign master1_sel = (master1.addr & SLAVE_MASK) == SLAVE_START;
  assign master2_sel = (master2.addr & SLAVE_MASK) == SLAVE_START;

  // Generate request signals from both masters
  logic master1_req, master2_req;
  assign master1_req = master1.req & master1_sel;
  assign master2_req  = master2.req  & master2_sel;

  typedef enum {M1, M2}  resp_t;
  resp_t resp_n, resp_q;

  always_comb begin
		// Written this as the deafult state to avoid latches
        resp_n      = resp_q;
        master1.gnt = 'b0;
        master2.gnt = 'b0;
        // Default assignment when there is no request here
        slave.req   = '0;
        slave.addr  = '0;
        slave.we    = '0;
        slave.be    = '0;
        slave.wdata = '0;
    if(master1_req && master2_req) begin
      // If there are two requests the same time, we give
      // data the priority
      slave.req   = master2.req;
      slave.addr  = master2.addr;
      slave.we    = master2.we;
      slave.be    = master2.be;
      slave.wdata = master2.wdata;
      master2.gnt = slave.gnt;
      master1.gnt = 'b0;
      resp_n      = M2;
    end else begin
      if(master1_req) begin
        slave.req   = master1.req;
        slave.addr  = master1.addr;
        slave.we    = master1.we;
        slave.be    = master1.be;
        slave.wdata = master1.wdata;
        master1.gnt = slave.gnt;
        master2.gnt = 'b0;
        resp_n      = M1;
      end
      if(master2_req) begin
        slave.req   = master2.req;
        slave.addr  = master2.addr;
        slave.we    = master2.we;
        slave.be    = master2.be;
        slave.wdata = master2.wdata;
        master2.gnt = slave.gnt;
        master1.gnt = 'b0;
        resp_n      = M2;
      end
      // No request
      if(!master1_req && !master2_req) begin
        resp_n      = resp_q;
        master1.gnt = 'b0;
        master2.gnt = 'b0;
        // Default assignment when there is no request here
        slave.req   = '0;
        slave.addr  = '0;
        slave.we    = '0;
        slave.be    = '0;
        slave.wdata = '0;
      end
    end
  end

  // Response channel MUX
  always_comb begin
    master1.rdata   = 'b0;
    master1.rvalid  = 'b0;
    master1.err     = 'b0;
    master2.rdata   = 'b0;
    master2.rvalid  = 'b0;
    master2.err     = 'b0;

    if(resp_q == M1) begin
      master1.rdata  = slave.rdata;
      master1.rvalid = slave.rvalid;
      master1.err    = slave.err;
    end else begin
      // M2
      master2.rdata  = slave.rdata;
      master2.rvalid = slave.rvalid;
      master2.err    = slave.err;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      resp_q <= M1;
    end else begin
      resp_q <= resp_n;
    end
  end  
endmodule
