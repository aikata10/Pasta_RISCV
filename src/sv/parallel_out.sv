`include "ibex.svh"

`define CONTROL_REGISTER  32'h0
`define DATA_REGISTER     32'h4

module parallel_out
(
  input  logic        clk_i,
  input  logic        rst_ni,
  bus_if.slave        bus,
  // External output
  output logic        parout_valid,
  output logic  [7:0] parout
);
  logic [7:0] data_n, data_p;
  logic [3:0] cnt_n, cnt_p;
  logic busy_n, busy_p;

  // Immediatly assign a grant
  assign bus.gnt = bus.req;
  // We do not generate errors
  assign bus.err = 1'b0;

  ////////////////////////////////////////////////////////
  // RValid Logic
  always_ff @(posedge clk_i) begin
    bus.rvalid <= bus.req;
  end

  ////////////////////////////////////////////////////////
  // Read logic
  always_ff @(posedge clk_i) begin
    bus.rdata <= 32'b0;

    if(bus.req && !bus.we) begin
      case (bus.addr[3:0])
        `CONTROL_REGISTER: bus.rdata <= {31'b0, busy_p};
        `DATA_REGISTER:    bus.rdata <= {24'b0, data_p};
      endcase
    end
  end

  ////////////////////////////////////////////////////////
  // Write logic
  always_comb begin
    busy_n       = busy_p;
    data_n       = data_p;
    cnt_n        = cnt_p;
    parout_valid = 1'b0;
    parout       = 8'b0;

    if(bus.req && bus.we) begin
      case (bus.addr[3:0])
        `CONTROL_REGISTER: begin
          if(!busy_p) begin
            busy_n = bus.wdata[0];
          end
        end
        `DATA_REGISTER: begin
          if(!busy_p) begin
            data_n = bus.wdata;
          end
        end
      endcase
    end

    // Ouput delay modelling
    if(busy_p) begin
      cnt_n = cnt_p + 1;
    end
    if(cnt_p == 4'hF) begin
      busy_n       = 1'b0;
      parout_valid = 1'b1;
      parout       = data_p;
    end
  end

  ////////////////////////////////////////////////////////
  // Register modelling
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      cnt_p  <= 4'b0;
      busy_p <= 1'b0;
      data_p <= 8'b0;
    end else begin
      cnt_p  <= cnt_n;
      busy_p <= busy_n;
      data_p <= data_n;
    end
  end
endmodule