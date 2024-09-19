`timescale 1ns/1ps

module lfsr_peripheral (
  input  logic       clk_i,
  input  logic       rst_ni,
  bus_if.slave       bus
);
  logic [31:0] ReadData_DN, ReadData_DP, LSFR_Data_D;
  logic [79:0] Indata;
  logic DataReadyLSFR_S, DataReady_SN, DataReady_SP;
  logic Enable_SN, Enable_SP;
  logic BusRead_S;

  assign BusRead_S  = (bus.req && !bus.we && bus.addr[3:0] == 4'b0);

  // Immediatly assign a grant
  assign bus.gnt = bus.req;
  // We do not generate errors
  assign bus.err = 1'b0;
  // Signal rvalid and set data
  assign bus.rdata  = ReadData_DP;
  assign bus.rvalid = DataReady_SP;
  assign Indata = bus.wdata;
  grain_lfsr # (
    .DATA_WIDTH   ( 32 )
  ) lfsr_i (
    .Clk_CI       ( clk_i           ),
    .Rst_RBI      ( rst_ni          ),
    .Enable_SI    ( Enable_SP       ),
    .Seed         ( Indata          ),
    .DataReady_SO ( DataReadyLSFR_S ),
    .Data_DO      ( LSFR_Data_D     )
  );
  
  always_comb begin
    ReadData_DN  = ReadData_DP;
    DataReady_SN = DataReady_SP;
    Enable_SN    = Enable_SP;

    // Read
    if(BusRead_S) begin
      Enable_SN  = 1'b1;
    end else if (DataReadyLSFR_S) begin
      Enable_SN  = 1'b0;
    end

    // Data ready signalling
    if (DataReadyLSFR_S) begin // set when LSFR is ready
      DataReady_SN = 1'b1;
      ReadData_DN  = LSFR_Data_D;  
    end else begin
      // Reset when data was read
      DataReady_SN = 1'b0;
      ReadData_DN  = '{default: 0};
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      Enable_SP     <= 1'b0;
      DataReady_SP  <= 1'b0;
      ReadData_DP   <= '{default: 0};
    end else begin
      Enable_SP     <= Enable_SN;
      DataReady_SP  <= DataReady_SN;
      ReadData_DP   <= ReadData_DN;
    end
  end
endmodule
