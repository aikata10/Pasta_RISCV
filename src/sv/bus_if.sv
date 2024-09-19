interface bus_if();
  logic req, gnt, rvalid, we, err;
  logic [3:0] be;
  logic [31:0] addr, rdata, wdata;


  modport master (
    output req,
    input  gnt,
    output addr,
    output we,
    output be,
    input  rvalid,
    output wdata,
    input  rdata,
    input  err
  );

  modport slave (
    input  req,
    output gnt,
    input  addr,
    input  we,
    input  be,
    output rvalid,
    input  wdata,
    output rdata,
    output err
  );

endinterface