
module eoc_controller (
  input  logic clk_i,
  input  logic rst_ni,
  bus_if.slave bus,
  // External output
  output logic eoc_o
);
  logic eoc_n, eoc_p;

  // Immediatly assign a grant
  assign bus.gnt = bus.req;
  // We do not generate errors
  assign bus.err = 1'b0;

  ////////////////////////////////////////////////////////
  // Output assignment
  assign eoc_o = eoc_p;

  ////////////////////////////////////////////////////////
  // RValid Logic
  always_ff @(posedge clk_i) begin
    bus.rvalid <= bus.req;
  end

  ////////////////////////////////////////////////////////
  // Read logic
  always_ff @(posedge clk_i) begin
    bus.rdata  <= 32'b0;

    if(bus.req && !bus.we && bus.addr[3:0] == 4'b0) begin
      bus.rdata <= {31'b0, eoc_p};
    end
  end

  ////////////////////////////////////////////////////////
  // Write logic
  always_comb begin
    eoc_n = eoc_p;

    if(bus.req && bus.we && bus.addr[3:0] == 4'b0) begin
      eoc_n = bus.wdata[0];
    end
  end

  ////////////////////////////////////////////////////////
  // Register modelling
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      eoc_p <= 1'b0;
    end else begin
      eoc_p <= eoc_n;
    end
  end
endmodule