`timescale 1ns/1ps

module gpo_peripheral (
  input  logic       clk_i,
  input  logic       rst_ni,
  bus_if.slave       bus,
  output logic [3:0] gpo_o
);
  logic [3:0] gpo_n, gpo_p;

  // Immediatly assign a grant
  assign bus.gnt = bus.req;
  // We do not generate errors
  assign bus.err = 1'b0;

  ////////////////////////////////////////////////////////
  // Output assignment
  assign gpo_o = gpo_p;

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
      bus.rdata <= {28'b0, gpo_p};
    end
  end

  ////////////////////////////////////////////////////////
  // Write logic
  always_comb begin
    gpo_n = gpo_p;

    if(bus.req && bus.we && bus.addr[3:0] == 4'b0) begin
      gpo_n = bus.wdata[3:0];
    end
  end

  ////////////////////////////////////////////////////////
  // Register modelling
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      gpo_p <= 'b0;
    end else begin
      gpo_p <= gpo_n;
    end
  end
endmodule
